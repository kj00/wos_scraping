patent_citation
========================================================
author: 
date: 
autosize: true




First Slide
========================================================

For more details on authoring R presentations please visit <https://support.rstudio.com/hc/en-us/articles/200486468>.

- Bullet 1
- Bullet 2
- Bullet 3

Slide With Code
========================================================
Time series of patent citation average by year





```
processing file: patent_citation.Rpres
Loading tidyverse: ggplot2
Loading tidyverse: tibble
Loading tidyverse: tidyr
Loading tidyverse: readr
Loading tidyverse: purrr
Loading tidyverse: dplyr
Conflicts with tidy packages ----------------------------------------------
filter(): dplyr, stats
lag():    dplyr, stats
-------------------------------------------------------------------------
data.table + dplyr code now lives in dtplyr.
Please library(dtplyr)!
-------------------------------------------------------------------------

Attaching package: 'data.table'

The following objects are masked from 'package:dplyr':

    between, first, last

The following object is masked from 'package:purrr':

    transpose


Attaching package: 'plotly'

The following object is masked from 'package:ggplot2':

    last_plot

The following object is masked from 'package:stats':

    filter

The following object is masked from 'package:graphics':

    layout

Parsed with column specification:
cols(
  pubyear = col_integer(),
  class = col_character(),
  V1 = col_double()
)
PhantomJS not found. You can install it with webshot::install_phantomjs(). If it is installed, please make sure the phantomjs executable can be found via the PATH variable.
Quitting from lines 42-51 (patent_citation.Rpres) 
 file(con, "rb") �ŃG���[:  �R�l�N�V�������J�����Ƃ��ł��܂��� 
 �Ăяo��:  knit ... value_fun -> fun -> html_screenshot -> readBin -> file
 �ǉ����:  �x�����b�Z�[�W: 
1:  normalizePath(path.expand(path), winslash, mustWork) ��: 
  path[1]=".\webshot222873e1251d.png": �w�肳�ꂽ�t�@�C����������܂���B
2:  file(con, "rb") ��: 
   �t�@�C�� 'C:\Users\Koji\AppData\Local\Temp\RtmpEh6wAw\file2228246c6600\webshot222873e1251d.png' ���J�����Ƃ��ł��܂���: No such file or directory 
 ���s����~����܂���
```
