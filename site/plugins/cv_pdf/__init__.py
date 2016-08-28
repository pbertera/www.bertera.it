# This is in `plugins/pdf/__init__.py`
import os
import tempfile

from pelican import signals

# The pandoc command. The CV is saved in a static `pdfs/` subdirectory.
CMD = ('pandoc {fn} -o content/pdfs/cv.pdf '
       '-V geometry:margin=1in '
       '--template=template.tex')


def generate_pdf(p):
    with tempfile.TemporaryDirectory() as tmpdir:
        print("Generating cv.pdf")
        with open('content/pages/cv.md', 'r') as f:
            contents = f.read()
        fn = os.path.join(tmpdir, 'cv.md')
        print("Tmp file: {fn}".format(fn=fn))
        contents = contents[contents.index('\n---') + 4:]
        # Add title and author in Markdown front matter.
        contents = ('---\n'
                    'title: Curriculum vitae\n'
                    'author: Pietro Bertera\n'
                    '---\n\n' +
                    contents)
        with open(fn, 'w') as f:
            f.write(contents)
        print("Executing: {cmd}".format(cmd=CMD.format(fn=fn)))
        os.system(CMD.format(fn=fn))


def register():
    # Create the PDF before generating the site.
    signals.initialized.connect(generate_pdf)
