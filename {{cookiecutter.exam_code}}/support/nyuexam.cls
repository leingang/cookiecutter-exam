{# This is a Jinja2 template for a latex package.  Both use braces heavily! 
    We use the raw ... endraw statements to surround untouched latex 
    and we have to escape literal braces.
#}
{% raw %}
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{nyuexam}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{exam}}
\ProcessOptions\relax
\LoadClass[11pt]{exam}

% metadata
\newcommand{\course}[2][\relax]{%
    \gdef\@course{#2}
    \xdef\@short@course{\ifx#1\relax#2\else#1\fi}
}
\usepackage{amsmath,
   amssymb,
   changepage,%\checkoddpage,\ifoddpage
   color,
   comment,
   graphicx,
   multicol,
   pdfpages,
   tikz,
   xstring,
   marvosym
}
\usepackage{xpatch}

% exam class settings
\usepackage[sf,bf]{titlesec}% set section titles in bold sans
\renewcommand{\maketitle}{
\noindent%
\edef\@TITLE{\uppercase{\@title}}%
    \bgroup\sffamily\bfseries\color{DeepViolet}
    \noindent\LARGE \@course \par
    \noindent\Large \@author \par
    \noindent\Huge  \@TITLE \par
    \vskip1em
    \noindent\large \@date \par\egroup
    \vskip2em
}


\usepackage{xcolor-nyu22}
% \usepackage{fontspec}
% \setmainfont{Frank Ruhl Libre}[
%     ItalicFont=*,
%     ItalicFeatures={FakeSlant},
%     SmallCapsFont={Latin Modern Roman Caps}
% ]
% \setsansfont{Gotham Book}[
%     BoldFont=Gotham Medium,
%     ItalicFont=Gotham Book Italic
% ]
\usepackage{charter}
\usepackage{montserrat}
\headrule% head rule across non-cover pages
\coverrunningheadrule% head rule non-first cover pages
\xpatchcmd{\run@fullhead}{\hrule}{\color{NyuViolet}\hrule}{}{\PatchFailed}
\xpatchcmd{\covrun@fullhead}{\hrule}{\color{NyuViolet}\hrule}{}{\PatchFailed}
\xpatchcmd{\@fullhead}{\hrule}{\color{NyuViolet}\hrule}{}{\PatchFailed}

% put logo on first cover page, no other header
\coverfirstpageheader{\begin{tikzpicture}[remember picture, overlay]
    \draw (current page.north west) ++ (0.25in,-0.25in) 
        node[anchor=north west] (logo)
        {\includegraphics[width=2.5in]{courant_short_black}};
  \end{tikzpicture}%
}{}{}

\newcommand{\headerfont}{\sffamily\color{DeepViolet}}
\header% all non-cover pages
    {\headerfont\@short@course}
    {\headerfont\@title}
    {\headerfont\@date}
    \coverrunningheader% cover pages except the first cover page
    {\run@lhead}
    {\run@chead}
    {\run@rhead}
\footer% all non-cover pages
%    {\UseVersionOf{\jobname.tex}, \UseDateOf{\jobname.tex}}
    {}
    {\thepage/\numpages}
%    {Revision \VCRevisionMod}
    {}
\coverfooter% footer on cover pages only
    {\run@lfoot}
    {}
    {\run@rfoot}

% Customize the styling of the optional argument to \answerline exam.cls
% uses the \CorrectChoice@Empasis token list for this.
\newcommand\CorrectAnswerStyle[1]{%
  \def\CorrectAnswer@Style{#1}%
}
\CorrectAnswerStyle{\everymath{\displaystyle}\CorrectChoice@Emphasis}
\xpatchcmd{\answerline}{\CorrectChoice@Emphasis}{\CorrectAnswer@Style}{}{\PatchFailed}

\shadedsolutions % needs color package
% multiple choice circles, needs tikz package
%:TODO make more like AMC
\tikzset{circled choice/.style={
    draw=MediumViolet2,
    shape=circle,
    minimum size=1.25em,
    inner sep=0pt,
    thick,
    text=LightViolet1,
    font=\sffamily
}}
\newcommand*\circled[1]{\tikz[baseline=(char.base)]{%
        \node[circled choice] (char) {#1};}}
\renewcommand\choicelabel{\circled{\Alph{choice}}}
\CorrectChoiceEmphasis{%
    \tikzset{circled choice/.append style={fill=NyuViolet}}%
    \color{NyuViolet}%
    \bfseries}
\checkboxchar{\circled{\phantom{A}}}
\checkedchar{\tikzset{circled choice/.append style={fill=NyuViolet}}\circled{\phantom{A}}}
\renewcommand{\questionshook}{%
    \settowidth{\leftmargin}{0pt}}
\renewcommand{\choiceshook}{\settowidth{\leftmargin}{\circled{W}.\hskip\labelsep\hskip 0em}}
\renewcommand{\checkboxeshook}{\settowidth{\leftmargin}{\circled{W}.\hskip\labelsep\hskip 0em}}
\makeatother

\setlength\linefillheight{36pt}
\colorfillwithlines
\colorlet{FillWithLinesColor}{MediumViolet2}


\newenvironment{instructions}{\noindent\sffamily\relax}{}



\setlength\answerclearance{0.5ex}

% strongly encourage a page break before each question
% h/t me https://tex.stackexchange.com/a/705383/1402
\appto{\questionshook}{\preto{\question}{\filbreak}}



\newcommand{\exammsgpageisblank}{(This page intentionally left blank. You may use it for scratch work.)}
\newcommand{\examblankpage}{
    \begin{center}
        \exammsgpageisblank    
    \end{center}
    \clearpage
}
\newcommand{\examcleardoublepage}{%
    \clearpage%
    \checkoddpage%
    \ifoddpage%
        \else
        \examblankpage
    \fi
}

% Some definitions needed to show students how to shade the answers in multiple choice
\newcommand*\samplecirc[1]{%
    \begin{tikzpicture}[baseline=(C.base)]
        \node[circled choice] (C) {#1};
\end{tikzpicture}}
\newcommand*\samplecircSoln[1]{%
    \begin{tikzpicture}[baseline=(C.base)]
        {\node[circled choice,fill=DarkGray] (C) {#1};} 
\end{tikzpicture}}

% Print the number of questions in a grading range in words.
% * Requires the fmtcount package
% * No h@ckery but still requires knowing the internals of \numqinrange.
% * fmtcount has more options like \Numberstring and \NUMBERstring
\usepackage{fmtcount}
\let\numstrqinrange\numqinrange
\patchcmd{\numstrqinrange}{\arabic}{\numberstring}{}{\PatchFailed}

\newenvironment{hint}{\par\noindent\textit{Hint.}}{}
{% endraw %}