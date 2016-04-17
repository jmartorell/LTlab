# LanguageTool lab

Some BASH and Python utilities to make the life of the Spanish rule developer for LanguageTool easier.

## Instructions:

Checkout the lab in any directory.

Soft link a directory called `languagetool` to the checkedout LanguageTool Java project.

i.e

```
  $ ln -s /home/pepe/ideaProjects/languagetool /home/pepe/lab/languagetool
```

Once and every time LanguageTool is built (i.e `mvn clean package -DskipTests`) run `relink.sh` to create or restore the links needed for the scripts to work.


## Contents

### Scripts

Described below. Most of them show a help text when ran without arguments.

### subdirectory `texts`

Texts to analyze go in the texts subdirectory Files are name coded

#### Short texts

* `tc-*.txt`

  These are short files intended to test small rulesets.

* `tc-segmentation.txt`

  Contains tricky sentences to check whether LT is segmentating in a correct way.

* `tc-falsosamigos-<lang1>-<lang2>.txt`

  False friends detection, lang1 is text language and lang2 is mock mother tongue language.

* `tc-<feature>-ok.txt`  
  `tc-<feature>-ko.txt`

  Intended to get output from correct and incorrect sentences, respectively. One sentence per line makes it easier to check later.
<feature> is any name you put; may be a category, rule group o whatever you want.

* `tc-<feature>.txt`

  Intended to get output from a feature. This is the most general, when you don't need or you don't want split correct and incorrect sentences.

#### Long texts

* `tl-*.txt`

  Long texts to apply widely the developed rules and see their effects in actual texts.

* `tl-1-<title>.txt`

  Plain text file containing an article or essay. Try to gather texts from different disciplines and styles.

* `tl-2-<title>.txt`

  Plain text file containing a book. As recommended with level 1, try to gather texts from different disciplines and styles.

* `da-vario.txt`

  Plain file with sentences with disambiguations.
  
#### Wikimedia backup dumps

Wikimedia backups dumps are compressed XML files with wikimedia sites' data and metadata.
They can be found at [Wikimedia Downloads](https://dumps.wikimedia.org/backup-index.html).
Once descompressed it is advisable to rename or link the files to a more predictable names.
  
* `eswiki-latest-pages-articles.xml`

  Compressed file available at
  XML file with a backup from the whole wikipedia.  
  Suggested link: `eswikipedia.xml`
  
* `eswikisource-<datestamp>-pages-articles.xml`

  XML file with a backup from the whole wikisource.
  Compressed file available clicking the `eswikisource` link and picking `eswikisource-<datestamp>-pages-articles.xml.bz2`  
  Suggested link: `eswikisource.xml`
  
* `eswikinews-<datestamp>-pages-articles.xml`
  
  XML file with a backup from the whole wikinews
  Compressed file available clicking the `eswikinews` link and picking `eswikinews-<datestamp>-pages-articles.xml.bz2`  
  Suggested link: `eswikinews.xml`
  
* `eswikibooks-<datestamp>-pages-meta-current.xml.bz2`
  
  XML file with a backup from the whole wikibooks
  Compressed file available clicking the `eswikibooks` link and picking `eswikibooks<datestamp>-pages-articles.xml.bz2`  
  Suggested link: `eswikibooks.xml`
  
* `eswikiversity-<datestamp>-pages-meta-current.xml.bz2`
  
  XML file with a backup from the whole wikiversity
  Compressed file available clicking the `eswikiversity` link and picking `eswikiversity<datestamp>-pages-articles.xml.bz2`  
  Suggested link: `eswikiversity.xml`
  
* `eswikivoyage-<datestamp>-pages-meta-current.xml.bz2`
  
  XML file with a backup from the whole wikivoyage
  Compressed file available clicking the `eswikivoyage` link and picking `eswikivoyage<datestamp>-pages-articles.xml.bz2`    
  Suggested link: `eswikivoyage.xml`
  
### Subdirectory `logs`, `logs_new`, `logs_old`

All logs go to `logs` and `logs_new` subdirectory. To create a comparison start, copy file to `logs_old` subdirectory

#### Scripts included:

* `comparetoeclipse.sh`

  Diff for grammar.xml and disambiguation.xml in both dist and dev dirs

* `fullcomparison.sh`

  Creates a file in /tmp/tmp.diff with all the diffs for all tc annd tl log files after a complete tc and tl run.

* `grammarconsole.sh`

  Interactive grammar console with debugger enabled.

* `grammartest.sh`

  View disambiguation from file texts/da-vario.txt in screen

* `logstats.sh`

  Gets the last line from every log file in logs, so you can collect performance indicators.

* `meld.sh`

  Opens a meld window with useful predefined comparisons.

* `nautilus.sh`

  Opens a nautilus tabbed window with useful predefined directories.

* `nautilus-newtab.sh`

  Opens/reuses a nautilus window with directories passed by arguments

* `stats.awk`

  Enhanced version of the script by Marcin Miłkowsky

* `stats.sh`

  Gets the last line from every log file in texts, so you can collect performance indicators.

* `testes-tc.sh`  
  `testes-tl.sh`

  Run languageTool on texts and generate regular logs.

* `stestes-tc.sh`  
  `stestes-tl.sh`

  Run languageTool on texts and generate logs both regular and ordered.

### Subdirectory `dict`

* `dictionary.sh`

  Utility to export/rebuild the POS dictionary.
  
* `split.awk`

  Splits the dictionary dump created by `dictionary.sh export` in more manageable parts.
  
* `resemble.sh`

  Integrate the parts created by `split.awk` the POS dictionary.
  
* `count.awk`

  Counts the entries in the dictionary dump.
  
* `multiword.awk`

  Processes files from [Ortografía española EAGLE](http://www.solosequenosenada.com/nexus/index.php?title=Ortografia_espa%C3%B1ola_EAGLE).
  These files need to be saved as UTF-8 encoded files and processed by the script `multiword-assembler.sh`

* `multiword-assembler.sh`

  Provides correct processing of script `multiword.awk`
