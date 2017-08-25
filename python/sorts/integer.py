from random import randint
import timeit

def python_sort(l):
  return sorted(l)

def human_sort(l):
  return sorted(l, key=int)

def selection_sort(l):
  clone = list(l)
  for i in xrange(len(clone)):
    m = i
    x = clone[i]
    for j in range(i + 1, len(clone)):
      if clone[j] < x:
        m, x = j, clone[j]
    if m != i:
      clone[m], clone[i] = clone[i], clone[m]
  return clone

def bubble_sort(l):
  clone = list(l)
  # start from the end
  for i, e in reversed(list(enumerate(l))):
    for j in range(i + 1, len(clone)):
       # swap if needed
       if clone[j - 1] > clone[j]:
         clone[j], clone[j - 1] = clone[j - 1], clone[j]
  return clone

def counting_sort(l):
  max_val = max(l)
  clone = []
  counter = [0] * (max_val + 1)
  for e in l:
    counter[e] += 1
  for i, cnt in list(enumerate(counter)):
    for t in xrange(cnt):
      clone.append(i)
  return clone

def print_results(name, time, time_per_call, calls_per_sec, iterations):
  print "%s | %s | %s | %s | %s" % (name[:30].rjust(30), str(round(time, 8)).rjust(12), str(round(time_per_call, 8)).rjust(12), str(round(calls_per_sec, 4)).rjust(12), str(iterations).rjust(12))

def run_timeit(name, code, iterations):
  setup = '''
from __main__ import python_sort, human_sort, selection_sort, bubble_sort, counting_sort
from random import randint
l = []
for i in range(1000):
  l.append(randint(0,1000))
'''
  time = timeit.timeit(setup = setup,
                       stmt = code,
                       number = iterations)
  time_per_call = time / float(iterations)
  calls_per_sec = float(iterations) / time
  print_results(name, time, time_per_call, calls_per_sec, iterations)


print "%s | %s | %s | %s | %s" % ('Function Name'.rjust(30), 'Total sec'.rjust(12), 'sec/call'.rjust(12), 'calls/sec'.rjust(12), 'Iterations'.rjust(12))

# l = []
# for i in range(10):
#   l.append(randint(0,100))
#
# print python_sort(l)
# print human_sort(l)
# print selection_sort(l)
# print bubble_sort(l)
# print counting_sort(l)

python_sort_code = '''
python_sort(l)
'''

human_sort_code = '''
human_sort(l)
'''

selection_sort_code = '''
selection_sort(l)
'''

bubble_sort_code = '''
bubble_sort(l)
'''

counting_sort_code = '''
counting_sort(l)
'''

run_timeit("built in", python_sort_code, 10000)
run_timeit("built in - human", human_sort_code, 10000)
run_timeit("selection_sort", selection_sort_code, 100)
run_timeit("bubble_sort", bubble_sort_code, 100)
run_timeit("counting_sort", counting_sort_code, 100)
