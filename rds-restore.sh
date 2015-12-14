#!/bin/bash

info() {
    echo "[`date +'%Y-%m-%d %T'`] $@"
}

die() {
    echo "[`date +'%Y-%m-%d %T'`] $@" >&2
    exit 1
}

help () {
    echo "
rds-restore.sh [options]

Options:
  -i|--instance-basename
    The basename of the instance that you want to create

  -s|--source-instance
    The name of the Source RDS instance to pull a snapshot from

  -d|--db-class
    The DB Class of the instance to create

  -e|--env
    The value of the env tag to add to the new instance

  --parameter-group
    The Parameter Group name to apply after instance creation

  --vpc-sg-ids
    The Security Group IDs to attach to the instance

  --help|help
    Displays this help message.
"
}

if [[ $1 =~ "help" ]]; then
    help
    exit 1
fi

while [[ $# > 1 ]]
do
    key="$1"
    case $key in
        -i|--instance-basename)
            instance_basename="$2"
            shift # past argument
            ;;
        -s|--source-instance)
            source_instance="$2"
            shift # past argument
            ;;
        -d|--db-class)
            db_class="$2"
            shift # past argument
            ;;
        -e|--env)
            env_tag="$2"
            shift # past argument
            ;;
        -r|--region)
            region="$2"
            shift
            ;;
        --parameter-group)
            parameter_group="$2"
            shift
            ;;
        --vpc-sg-ids)
            sg_ids_csv="$2"
            shift
            ;;
        --hosted-zone-id)
            hosted_zone_id="$2"
            shift
            ;;
        --dns-record)
            dns_record="$2"
            shift
            ;;
        --aws-account-id)
            accountid="$2"
            shift
            ;;
        --remove-old-instance)
            do_remove="$2"
            shift
            ;;
        *)
            # unknown option
            info "Unknown option '$key'"
            ;;
    esac
    shift
done

gen_dns_batch_filename() {
    echo "/tmp/${hosted_zone_id}-${dns_record}.json"
}

gen_instance_name() {
    echo "$instance_basename-`date +'%Y-%m-%d-%H%M%S'`"
}

# Set Instance Name
instance_name="$(gen_instance_name)"

gen_vpc_id_string() {
    echo $sg_ids_csv | tr ',' '\n' | awk '{print "\""$1"\""}' | tr '\n' ' '
}

vpc_security_groups="$(gen_vpc_id_string)"

# Select Latest Snapshot
get_snapshot() {
    aws rds describe-db-snapshots --db-instance-identifier $source_instance --region $region | jq -r '.DBSnapshots[-1].DBSnapshotIdentifier'
}

get_status() {
    aws rds describe-db-instances --db-instance-identifier $instance_name --region $region | jq -r '.DBInstances[0].DBInstanceStatus'
}

get_endpoint() {
    aws rds describe-db-instances --db-instance-identifier $instance_name --region $region | jq -r '.DBInstances[0].Endpoint.Address'
}

get_arn() {
    echo "arn:aws:rds:$region:$accountid:db:$source_instance"
}

gen_finder() {
    echo "rds-restore::$env_tag::"
}

get_old_instance_name() {
    arn="$(get_arn)"
    finder="$(gen_finder)"

    cmd="aws rds list-tags-for-resource --resource-name $arn --region $region | grep '$finder' | cut -c 23- | sed 's/$finder//' | sed 's/\",//'"
    eval $cmd
}

old_instance_name="$(get_old_instance_name)"

set_new_instance_tag() {
    arn="$(get_arn)"
    tag_key="current-${env_tag}"
    tag_value="rds-restore::${env_tag}::${instance_name}"

    cmd="aws rds add-tags-to-resource --resource-name $arn --region $region --tags Key=$tag_key,Value=$tag_value"
    info "Executing: $cmd"
    eval $cmd
}

delete_old_instance() {
    cmd="aws rds delete-db-instance --db-instance-identifier $old_instance_name --skip-final-snapshot --region $region"
    info "Executing: $cmd"
    eval $cmd
}

create_instance() {
    cmd="aws rds restore-db-instance-from-db-snapshot --db-instance-identifier $instance_name --db-snapshot-identifier $snapshot --db-instance-class $db_class --no-multi-az --publicly-accessible --no-auto-minor-version-upgrade --tags Key=env,Value=$env_tag --db-subnet-group-name production-public --region $region "
    info "Executing: $cmd"
    eval $cmd
}

update_instance_parameter_and_security_groups() {
    cmd="aws rds modify-db-instance --db-instance-identifier $instance_name --apply-immediately --db-parameter-group-name $parameter_group --backup-retention-period 0 --vpc-security-group-ids $vpc_security_groups --region $region "
    info "Executing: $cmd"
    eval $cmd
}

reboot_instance() {
    cmd="aws rds reboot-db-instance --db-instance-identifier $instance_name --region $region "
    info "Executing: $cmd"
    eval $cmd
}

update_dns() {
    batch_filename="$(gen_dns_batch_filename)"
    cat <<EOF > $batch_filename
{
  "Comment": "Automated update of $dns_record to $endpoint",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$dns_record",
        "Type": "CNAME",
        "TTL": 60,
        "ResourceRecords": [
          {
            "Value": "$endpoint"
          }
        ]
      }
    }
  ]
}
EOF
    cmd="aws route53 change-resource-record-sets --region $region  --hosted-zone-id $hosted_zone_id --change-batch file://$batch_filename"
    info "Executing: $cmd"
    eval $cmd
}

is_updating() {
  [[ "$(get_status)" != "available" ]] && return 0
  return 1
}
 
is_available() {
  [[ "$(get_status)" == "available" ]] && return 0
  return 1
}

poll_status() {
    start=$(date -u +%s)
    deadline=$((start + 3600))
    echo -n  "[`date +'%Y-%m-%d %T'`] Polling..."
    while is_updating && [[ $(date -u +%s) -le $deadline ]]; do
        echo -n .
        sleep 15
    done
    echo " "
    
    info "Update complete"
}

# Get Snapshot
snapshot="$(get_snapshot)"
info "Snapshot: $snapshot"

# Create
info "Creating Instance: $instance_name"
create_instance

# Status
info "Polling for status 'available' status."
poll_status

info "Sleeping for 10 seconds..."
sleep 10

# Update Parameter Group
info "Updating Parameter Group on $instance_name to $parameter_group and applying proper security groups"
update_instance_parameter_and_security_groups

# Status
info "Polling for status 'available' status."
poll_status

info "Sleeping for 30 seconds..."
sleep 30

# Reboot
info "Rebooting instance: $instance_name"
reboot_instance

# Check Status
info "Polling for status 'available' status."
poll_status

info "Sleeping for 10 seconds..."
sleep 10

# Get DNS Name
endpoint="$(get_endpoint)"
info "Ready to update DNS records with: $endpoint"

if [[ ! -z "$dns_record" ]]
then
    info "Updating DNS for $dns_record"
    update_dns
fi

if [[ ! -z "$do_remove" ]]
then
    if [ "$do_remove" == "true" ]
    then
        info "Old Instance: $old_instance_name"
        delete_old_instance
    else
        info "Will not remove old instance. Value was not 'true'"
    fi
else
    info "Will not remove old instance."
fi

# Update Tags
info "Setting new tags for restored instance on master host"
set_new_instance_tag

info "Process complete!"

exit 0
