% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/dfm-main.R
\name{dfm}
\alias{as.dfm}
\alias{dfm}
\alias{dfm.character}
\alias{dfm.corpus}
\alias{is.dfm}
\title{create a document-feature matrix}
\usage{
dfm(x, ...)

\method{dfm}{character}(x, verbose = TRUE, clean = TRUE, stem = FALSE,
  ignoredFeatures = NULL, keptFeatures = NULL, matrixType = c("sparse",
  "dense"), language = "english", fromCorpus = FALSE, bigrams = FALSE,
  thesaurus = NULL, dictionary = NULL, dictionary_regex = FALSE,
  addto = NULL, ...)

\method{dfm}{corpus}(x, verbose = TRUE, clean = TRUE, stem = FALSE,
  ignoredFeatures = NULL, keptFeatures = NULL, matrixType = c("sparse",
  "dense"), language = "english", groups = NULL, bigrams = FALSE,
  thesaurus = NULL, dictionary = NULL, dictionary_regex = FALSE,
  addto = NULL, ...)

is.dfm(x)

as.dfm(x)
}
\arguments{
\item{x}{corpus or character vector from which to generate the document-feature matrix}

\item{...}{additional arguments passed to \code{\link{clean}}}

\item{verbose}{display messages if \code{TRUE}}

\item{clean}{if \code{FALSE}, do no cleaning of the text.  This offers a
one-argument easy method to turn off any cleaning of the texts during
construction of the dfm.}

\item{stem}{if \code{TRUE}, stem words}

\item{ignoredFeatures}{a character vector of user-supplied features to
ignore, such as "stop words".  Formerly, this was a Boolean option for
\code{stopwords = TRUE}, but requiring the user to supply the list
highlights the choice involved in using any stopword list.  To access one
possible list (from any list you wish), use \code{\link{stopwords}()}.}

\item{keptFeatures}{a use supplied regular expression defining which features
to keep, while excluding all others.  This can be used in lieu of a
dictionary if there are only specific features that a user wishes to keep.
To extract only Twitter usernames, for example, set \code{keptFeatures =
"^@\\\w+\\\b"} and make sure that \code{removeTwitter = FALSE} as an
additional argument passed to \link{clean}.  (Note: \code{keptFeatures =
"^@"} will also retrieve usernames, but does not enforce the username
convention that a username must contain one and only one \code{@} symbol,
at the beginning of the username.)}

\item{matrixType}{if \code{dense}, produce a dense matrix; or it
\code{sparse} produce a sparse matrix of class \code{dgCMatrix} from the
\pkg{\link{Matrix}} package.}

\item{language}{Language for stemming and stopwords.  Choices are
\code{danish}, \code{dutch}, \code{english}, \code{finnish}, \code{french},
\code{german}, \code{hungarian}, \code{italian}, \code{norwegian},
\code{porter}, \code{portuguese}, \code{romanian}, \code{russian},
\code{spanish}, \code{swedish}, \code{turkish} for stemming, and
\code{SMART}, \code{danish}, \code{english}, \code{french},
\code{hungarian}, \code{norwegian}, \code{russian}, \code{swedish},
\code{catalan}, \code{dutch}, \code{finnish}, \code{german},
\code{italian}, \code{portuguese}, \code{spanish}, \code{arabic} for
stopwords.}

\item{fromCorpus}{a system flag used internally, soon to be phased out.}

\item{bigrams}{include bigrams as well as unigram features, if \code{TRUE}}

\item{thesaurus}{A list of character vector "thesaurus" entries, in a
dictionary list format, which can also include regular expressions  if
\code{dictionary_regex} is \code{TRUE} (see examples).  Note that unlike
dictionaries, each entry in a thesaurus key must be unique, otherwise only
the first match in the list will be used.  Thesaurus keys are converted to
upper case to create a feature label in the dfm, as a reminder that this
was not a type found in the text, but rather the label of a thesaurus key.}

\item{dictionary}{A list of character vector dictionary entries, including
regular expressions (see examples)}

\item{dictionary_regex}{\code{TRUE} means the dictionary is already in
regular expression format, otherwise it will be converted from "wildcard"
format}

\item{addto}{\code{NULL} by default, but if an existing dfm object is
specified, then the new dfm will be added to the one named. If both
\link{dfm}'s are built from dictionaries, the combined dfm will have its
\code{Non_Dictionary} total adjusted.}

\item{groups}{Grouping variable for aggregating documents}
}
\value{
A \link{dfm-class} object containing a sparse matrix representation
  of the counts of features by document, along with associated settings and
  metadata.

  If you used \code{matrixType = "dense"} then the return is an old-style S3
  matrix class object with additional attributes representing meta-data.
}
\description{
Create a sparse matrix document-feature matrix from a corpus or a vector of texts.  The sparse
matrix construction uses  the
\pkg{Matrix} package, and is both much faster and much more memory efficient
than the corresponding dense (regular \code{matrix}) representation.  For details on the
structure of the dfm class, see \link{dfm-class}.
}
\details{
New as of v0.7: All dfms are by default sparse, a change from the previous behaviour.
You can still create the older (S3) dense matrix type dfm object, but you will receive
a disapproving warning message while doing so, suggesting you make the switch.

\code{is.dfm} returns \code{TRUE} if and only if its argument is a \link{dfm}.

\code{as.dfm} coerces a matrix or data.frame to a dfm
}
\examples{
# with inaugural texts
(size1 <- object.size(dfm(inaugTexts, matrixType="sparse")))
(size2 <- object.size(dfm(inaugTexts, matrixType="dense")))
cat("Compacted by ", round(as.numeric((1-size1/size2)*100), 1), "\%.\\n", sep="")

# with stopwords English, stemming, and dense matrix
dfmsInaug2 <- dfm(inaugCorpus, ignoredFeatures = stopwordsGet(), stem=TRUE, matrixType="dense")

## with dictionaries
mycorpus <- subset(inaugCorpus, Year>1900)
mydict <- list(christmas=c("Christmas", "Santa", "holiday"),
               opposition=c("Opposition", "reject", "notincorpus"),
               taxing="taxing",
               taxation="taxation",
               taxregex="tax*",
               country="united states")
dictDfm <- dfm(mycorpus, dictionary=mydict)
dictDfm

## with the thesaurus feature
mytexts <- c("The new law included a capital gains tax, and an inheritance tax.",
             "New York City has raised a taxes: an income tax and a sales tax.")
mydict <- list(tax=c("tax", "income tax", "capital gains tax", "inheritance tax"))
dfm(phrasetotoken(mytexts, mydict), thesaurus=lapply(mydict, function(x) gsub("\\\\s", "_", x)))
# pick up "taxes" with "tax" as a regex
dfm(phrasetotoken(mytexts, mydict), thesaurus=list(anytax="tax"), dictionary_regex=TRUE)

## removing stopwords
testText <- "The quick brown fox named Seamus jumps over the lazy dog also named Seamus, with
             the newspaper from a a boy named Seamus, in his mouth."
testCorpus <- corpus(testText)
settings(testCorpus, "stopwords")
dfm(testCorpus, stopwords=TRUE)

## keep only certain words
dfm(testCorpus, keptFeatures="s$", verbose=FALSE)  # keep only words ending in "s"
testTweets <- c("My homie @justinbieber #justinbieber shopping in #LA yesterday #beliebers",
                "2all the ha8ers including my bro #justinbieber #emabiggestfansjustinbieber",
                "Justin Bieber #justinbieber #belieber #fetusjustin #EMABiggestFansJustinBieber")
dfm(testTweets, keptFeatures="^#")  # keep only hashtags


\dontrun{
# try it with approx 35,000 court documents from Lauderdale and Clark (200?)
load('~/Dropbox/QUANTESS/Manuscripts/Collocations/Corpora/lauderdaleClark/Opinion_files.RData')
txts <- unlist(Opinion_files[1])
names(txts) <- NULL

# dfms without cleaning
require(Matrix)
system.time(dfmsBig <- dfm(txts, clean=FALSE, verbose=FALSE))
object.size(dfmsBig)
dim(dfmsBig)
# compare with tm
require(tm)
tmcorp <- VCorpus(VectorSource(txts))
system.time(tmDTM <- DocumentTermMatrix(tmcorp))
object.size(tmDTM)
dim(tmDTM)

# with cleaning - the gsub() calls in clean() take a long time
system.time(dfmsBig <- dfm(txts, clean=TRUE, additional="[-_\\\\x{h2014}]"))
object.size(dfmsBig)
dim(dfmsBig)
# 100 top features
topf <- colSums(dfmsBig)
names(topf) <- colnames(dfmsBig)
head(sort(topf, decreasing=TRUE), 100)
}
# sparse matrix from a corpus
mydfm <- dfm(inaugCorpus)
mydfmGrouped <- dfm(inaugCorpus, groups = "President")
}
\author{
Kenneth Benoit
}

