prof:
	bash -c 'source /home/groups/aaiken/eslaught/tutorial/env.sh && for f in prof*_0.gz; do legion_prof.py -f -o $$(basename $$f _0.gz) $$f; done'

spy:
	source /home/groups/aaiken/eslaught/tutorial/env.sh && legion_spy.py -de spy_*.log

clean:
	rm -rf *.gz *.log *.out *.pdf legion_prof
