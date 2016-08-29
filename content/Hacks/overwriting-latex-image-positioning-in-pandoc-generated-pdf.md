Title: Overwriting Latex image positioning in pandoc generated pdf
Date: 2015-04-14 20:25
Author: admin
Tags: Latex, markdown
Slug: overwriting-latex-image-positioning-in-pandoc-generated-pdf
Status: published

Pandoc is a very powerful tool, I'm extensively using it for writing
documentation, papers and so on.  
You can generate pdf, html, docx and many other formats trough a
compilation of markdown source file.

Often I use it to produce nice PDF documents, in this process your
Markdown document is parsed and rendered using a Latex template, you can
obtain the default template using the command:

`pandoc -D latex`

Unfortunately all images with a caption tet are rendered in Latex using
the **htbp** floating positioning, this is hardcoded in pandoc.

Markdown code:  
`![I/O connector](img/1.jpg)`

Latex code:

```
\begin{figure}[htbp]
\centering
\includegraphics{img/1.jpg}
\caption{I/O connector}
\end{figure}
```

Sometimes the [htbp] positioning doesn't fits my needs and I prefer to
use the fixed [H] positioning.  
Over the web you can find a lot of solutions suggesting to compile your
Markdown in a Latex file, parse the file with sed and then use pdflatex
to generate the PDF.

Now, I found a way to overwrite the Latex {figure} environment directly
into the Latex template:

```
% Overwrite \begin{figure}[htbp] with \begin{figure}[H]
\usepackage{float}
\let\origfigure=\figure
\let\endorigfigure=\endfigure
\renewenvironment{figure}[1][]{%
   \origfigure[H]
}{%
   \endorigfigure
}
```
