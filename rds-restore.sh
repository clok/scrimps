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
		aws rds describe-db-snapshots --db-instance-identifier $source_instance | jq -r '.DBSnapshots[-1].DBSnapshotIdentifier'
}

get_status() {
		aws rds describe-db-instances --db-instance-identifier $instance_name | jq -r '.DBInstances[0].DBInstanceStatus'
}

get_endpoint() {
		aws rds describe-db-instances --db-instance-identifier $instance_name | jq -r '.DBInstances[0].Endpoint.Address'
}

create_instance() {
		cmd="aws rds restore-db-instance-from-db-snapshot --db-instance-identifier $instance_name --db-snapshot-identifier $snapshot --db-instance-class $db_class --no-multi-az --publicly-accessible --no-auto-minor-version-upgrade --tags Key=env,Value=$env_tag --db-subnet-group-name production-public"
		info "Executing: $cmd"
		eval $cmd
}

update_instance_parameter_and_security_groups() {
		cmd="aws rds modify-db-instance --db-instance-identifier $instance_name --apply-immediately --db-parameter-group-name $parameter_group --backup-retention-period 0 --vpc-security-group-ids $vpc_security_groups"
		info "Executing: $cmd"
		eval $cmd
}

reboot_instance() {
		cmd="aws rds reboot-db-instance --db-instance-identifier $instance_name"
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
		cmd="aws route53 change-resource-record-sets --hosted-zone-id $hosted_zone_id --change-batch file://$batch_filename"
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
		
		if is_updating ; then
				die "Update timed out"
		fi
		
		info "Update complete!"
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

# Update Parameter Group
info "Updating Parameter Group on $instance_name to $parameter_group and applying proper security groups"
update_instance_parameter_and_security_groups

# Status
info "Polling for status 'available' status."
poll_status

# Reboot
info "Rebooting instance: $instance_name"
reboot_instance

# Check Status
info "Polling for status 'available' status."
poll_status

# Get DNS Name
endpoint="$(get_endpoint)"
info "Ready to update DNS records with: $endpoint"

if [[ ! -z "$dns_record" ]]
then
		info "Updating DNS for $dns_record"
		update_dns
fi

info "Process complete!"

exit 0
