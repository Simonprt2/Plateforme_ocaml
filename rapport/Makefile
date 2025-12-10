all:
	# -shell escape : nécessaire pour minted
	pdflatex rapport-abdorohmang-pariat.tex
	# on compile une deuxième fois pour les références
	pdflatex rapport-abdorohmang-pariat.tex

clean:
	rm -rf *bak *~ *out *log *aux _minted-report *.aex
