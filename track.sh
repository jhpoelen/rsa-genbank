curl "https://cch2.org/portal/content/dwca/rss.xml"\
 | xmllint --format -\
 | grep RSA\
 | grep link\
 | grep -oE "https.*.zip"\
 | xargs -L1 preston track
