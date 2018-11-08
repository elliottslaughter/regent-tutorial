prof:
	source /home/groups/aaiken/eslaught/tutorial/env.sh && legion_prof.py -f prof_*.gz

spy:
	source /home/groups/aaiken/eslaught/tutorial/env.sh && legion_spy.py -de spy_*.log

clean:
	rm -rf *.gz *.log *.out *.pdf legion_prof
