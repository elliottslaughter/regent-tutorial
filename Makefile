prof:
	legion_prof.py -f prof_*.gz

spy:
	legion_spy.py -de spy_*.log

clean:
	rm -f *.gz *.log *.out
