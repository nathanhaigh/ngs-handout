Here you will find information on how to write a workshop handout in LaTeX to
get consistent styling for a professional look and feel.

Trainer/Trainee Manual
======================
By changing the boolean value of the ```trainermanual``` toggle you can output
either the trainer's manual or the trainee's handout.

By setting the toggle to false (the default), you output the traines's handout:

    \settoggle{trainermanual}{false}

This document has the following styling:
* Paragraph spacing within the ```questions``` environment is set to 2cm to
  provide the trainee sufficient space to write the answers.
* Text within the ```answer``` environment is not output. 

By setting the toggle to true, you output the trainer's manual:

    \settoggle{trainermanual}{true}

This document has the following content and styling differences to the
trainee's handout:
* Pale red background colouring of the front page.
* The text, "TRAINER'S MANUAL", in large, red text in the footer of most pages
  and the header of the front page.
* Text within the ```answer``` environment is displayed in red text.
* Paragraph spacing within the ```questions``` environment is unmodified and 
  consistent with the the rest of the document.

Code
====
Currently only bash/shell code is supported.

Bash code that you expect trainees to execute at a terminal should be placed
inside the ```lstlisting``` environment:

    begin{lstlisting}
    code to be executed in here
    end{lstlisting}

This block is styled with line numbers, easy to copy-and-paste text and
automatic line wrapping with the bash line continuation character ```\```. Thus
the support for bash/shell only at this stage.

Line numbers are not selected when multiple lines are copy-and-pasted. However,
support for this feature is not supported by all PDF viewers. Acrobat Reader
does support this feature. However,if this feature is not widely supported, we
may remove line numbers from the styling of code listings.

Q & A Sections
==============
Questions are placed inside a ```questions``` environment. This environment is
styled with a pale yellow background, a left-margin "Q" icon and 2cm paragraph
spacing to provide sufficient space for trainees to write answers.

    begin{questions}
    What is the FASTQ encoding used in the file?
    
    What length are the reads?
    end{questions}

Answers to questions are placed in an ```answer``` environment nested inside
the ```questions``` environment. This means that
both questions and their answers can be maintained in a single document:

    begin{questions}
    What is the FASTQ encoding used in the file?
    begin{answer}
    Sanger Phred+33
    end{answer}
    
    What length are the reads?
    begin{answer}
    100 bp
    end{answer}
    end{questions}

Output
of answers is controlled by the ```trainermanual``` toggle. Output is suppressed
by setting the value to ```false``` (default). Answers are output if the toggle is
set to ```true```:

    \settoggle{trainermanual}{true}
    
    

