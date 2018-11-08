prof:
	bash -c 'source /home/groups/aaiken/eslaught/tutorial/env.sh && for f in prof*_0.gz; do legion_prof.py -f -o $$(basename $$f _0.gz) $$f; done'

spy:
	bash -c 'source /home/groups/aaiken/eslaught/tutorial/env.sh && for f in spy*_0.log; do dir=$$(basename $$f _0.log); mkdir -p $$dir; pushd $$dir; legion_spy.py -de ../$$f; popd; done'

clean:
	rm -f *.gz *.log *.out *.pdf
	rm -rf prof* spy*
