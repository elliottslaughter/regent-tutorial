prof:
	legion_prof.py -o ~/public_html/prof prof0

spy:
	legion_spy.py -de spy0
	mv dataflow_main_1.pdf ~/public_html/dataflow.pdf
	mv event_graph_main_1.pdf ~/public_html/event.pdf

clean:
	rm *~ prof* spy* r*sh*e* r*sh*o*
