import math
import string
import random
import timeit
import psutil

ITERATIONS = 1000

# QuickSort
# sub perl_sort {
#   my $array = shift;
#
#   return sort @$array;
# }
#
def python_sort(array):
  return sorted(array)

# sub dict_sort {
#   my $array = shift;
#   return sort {
#     my $da = lc $a;
#     my $db = lc $b;
#     $da =~ s/\W+//g;
#     $db =~ s/\W+//g;
#     $da cmp $db;
#   } @$array;
# }
def dictionary_sort(array):
  import re
  convert = lambda text: int(text) if text.isdigit() else re.sub('[\s]', '', text.lower())
  return sorted(array, key=convert)

# sub dict_opt_sort {
#   my $array = shift;
#   return map { $_->[0] }
#     sort { $a->[0] cmp $b->[0] }
#      map {
#        my $d = lc;
#        $d =~ s/[\W_]//g;
#        [ $_, $d ];
#      }
#     @$array;
# }
def dictionary_optimized_sort(array):
  return dictionary_sort(array)

def print_results(name, time, time_per_call, calls_per_sec):
  print "%s | %s | %s | %s" % (name[:30].rjust(30), str(round(time, 8)).rjust(12), str(round(time_per_call, 8)).rjust(12), str(round(calls_per_sec, 4)).rjust(12))

def random_string():
  return ''.join(random.choice(string.ascii_uppercase + string.ascii_lowercase) for _ in range(8))

print "%s | %s | %s | %s" % ('Function Name'.rjust(30), 'Total sec'.rjust(12), 'sec/call'.rjust(12), 'calls/sec'.rjust(12))

setup = '''
from __main__ import random_string, python_sort, dictionary_sort, dictionary_optimized_sort
array = []
for i in range(1000):
  array.append(random_string())
'''

python_sort_code = '''
python_sort(array)
'''

dictionary_sort_code = '''
dictionary_sort(array)
'''

dictionary_optimized_sort_code = '''
dictionary_optimized_sort(array)
'''

time = timeit.timeit(setup = setup,
                     stmt = python_sort_code,
                     number = ITERATIONS)
time_per_call = time / float(ITERATIONS)
calls_per_sec = float(ITERATIONS) / time
print_results("python sort", time, time_per_call, calls_per_sec)

time = timeit.timeit(setup = setup,
                     stmt = dictionary_sort_code,
                     number = ITERATIONS)
time_per_call = time / float(ITERATIONS)
calls_per_sec = float(ITERATIONS) / time
print_results("dictionary sort", time, time_per_call, calls_per_sec)

time = timeit.timeit(setup = setup,
                     stmt = dictionary_optimized_sort_code,
                     number = ITERATIONS)
time_per_call = time / float(ITERATIONS)
calls_per_sec = float(ITERATIONS) / time
print_results("dictionary optimized sort", time, time_per_call, calls_per_sec)
