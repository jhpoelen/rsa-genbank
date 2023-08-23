# rsa-genbank
prototype workflows to link California Botanic Garden Herbarium specimen records at (RSA) with associated NIH NCBI GenBank


## Step 1. Select GenBank Records mentioning "RSA"

```bash
preston cat\
 --no-progress\
 --no-cache\
 --remote https://zenodo.org/record/8117720/files/,https://biokic6.rc.asu.edu/preston/gbpln\
 hash://sha256/5f2ac721f6c24c95b9775420135e3d16a3b76761d4ac62981990f27425a0b8bb\
 | gunzip\
 | grep -E '[^a-zA-Z]RSA[^a-zA-Z]'\
 > rsa.json
```

where ```head -n1 | jq .``` results in:

```json
{
  "accession": "AF022124",
  "http://www.w3.org/2000/01/rdf-schema#seeAlso": "https://ncbi.nlm.nih.gov/nuccore/AF022124",
  "definition": "Fremontodendron mexicanum ribulose 1,5-bisphosphate carboxylase large subunit (rbcL) gene, chloroplast gene encoding chloroplast protein, partial cds.",
  "organism": "Fremontodendron mexicanum",
  "specimen_voucher": "Thorne 54717, RSA",
  "db_xref": "taxon:66666",
  "http://www.w3.org/ns/prov#wasDerivedFrom": "line:gz:hash://sha256/bdef161f6970138ad62dfa1686e00cfccc007fe025e6213c6b9a2c177eddc40f!/L2303661-L2303737",
  "http://www.w3.org/1999/02/22-rdf-syntax-ns#type": "genbank-flatfile"
}
```

## Step 2. Inspect Specimen Vouchers

```bash
cat rsa.json\
 | jq --raw-output -c '.["specimen_voucher"]'\
 | sort\
 | uniq\
> rsa_specimen_vouchers.txt
```

resulting in ```cat rsa_specimen_vouchers.txt  | wc -l``` or 2798 unique vouchers, with first 10 being:

```
11476 (RSA)
14262 (RSA-POM)
17320 (RSA)
17604 (RSA-POM)
18208 (RSA-POM)
18923 (1995) (Rancho Santa An
18923 (1995) (RSA)
20543 (RSA-POM)
209700 RSA
2290 (RSA)
```

and last 10:

```
Zuniga 614 (RSA)
Zuniga 615 (RSA)
Zuniga 620 (RSA)
Zuniga 626 (RSA)
Zuniga 687 (RSA)
Zuniga 702 (RSA)
Zuniga 772 (RSA)
Zuniga 773 (RSA)
Zuniga 774 (RSA)
Zuniga 775 (RSA)
```

## Step 3. Track RSA Specimen Records

Via CCH2 portal rss feed, locate the candidate RSA DwC-A:

```bash
curl "https://cch2.org/portal/content/dwca/rss.xml"\
 | xmllint --format -\
 | grep RSA\
 | grep link\
 | grep -oE "https.*.zip"
```

yielding 

```https://cch2.org/portal/content/dwca/RSA-VascularPlants_DwC-A.zip```

so, 

```bash
curl "https://cch2.org/portal/content/dwca/rss.xml"\
 | xmllint --format -\
 | grep RSA\
 | grep link\
 | grep -oE "https.*.zip"\
 | xargs -L1 preston track
```

results in the command: ```preston track https://cch2.org/portal/content/dwca/RSA-VascularPlants_DwC-A.zip```

In our case, this resulted in a Preston package with id, as retrieved via ```preston head```, of  ```hash://sha256/747a1979d9196e55e8f24608df0e7d8aae5c73eac1c464bd9c63c94ba5a09e6e```.

## Step 4. Attempt Finding One Candidate RSA-GenBank Link

Some GenBank flat file mentions a specimen_voucher ```Zuniga 775 (RSA)``` appears to be a name (i.e., Zuniga) a record/collector number (i.e., 775) and the institution code (i.e., RSA).

Now, search using the versioned RSA DwC-A by:

```bash
preston ls\
 --anchor hash://sha256/747a1979d9196e55e8f24608df0e7d8aae5c73eac1c464bd9c63c94ba5a09e6e\
 --remote https://raw.githubusercontent.com/jhpoelen/rsa-genbank/main/data,https://linker.bio\
 | preston dwc-stream\
 | grep Zuniga\
 | grep -E '[^0-9]775[^0-9]'\
 | jq . 
```

yields no hits.

However, when selecting a more general search, it appears that the name is actually Zúñiga (not Zuniga). 

with this in mind

```bash
preston ls\
 --anchor hash://sha256/747a1979d9196e55e8f24608df0e7d8aae5c73eac1c464bd9c63c94ba5a09e6e\
 --remote https://raw.githubusercontent.com/jhpoelen/rsa-genbank/main/data,https://linker.bio\
 | preston dwc-stream\
 | grep Zúñiga\
 | grep -E '[^0-9]775[^0-9]'\
 | jq .
```

yielded still no hits.

However, ```Vincent 8588 (RSA)``` did yield a hit using:

```
preston ls\
 --anchor hash://sha256/747a1979d9196e55e8f24608df0e7d8aae5c73eac1c464bd9c63c94ba5a09e6e\
 --remote https://raw.githubusercontent.com/jhpoelen/rsa-genbank/main/data,https://linker.bio\
 | preston dwc-stream\
 | grep "Vincent"\
 | jq -c 'select(.["http://rs.tdwg.org/dwc/terms/recordNumber"] == "8588")'
```

```json
{
  "http://www.w3.org/ns/prov#wasDerivedFrom": "line:zip:hash://sha256/bc528f6e35f0f694e3cba5c3cefb5a8dc0950da671384e9eea647f3bcf6de437!/occurrences.csv!/L545273",
  "http://www.w3.org/1999/02/22-rdf-syntax-ns#type": "http://rs.tdwg.org/dwc/terms/Occurrence",
  "http://rs.tdwg.org/dwc/text/id": "999496",
  "http://rs.tdwg.org/dwc/terms/taxonID": "103401",
  "http://rs.tdwg.org/dwc/terms/subgenus": null,
  "http://rs.tdwg.org/dwc/terms/verbatimDepth": null,
  "http://rs.tdwg.org/dwc/terms/occurrenceID": "8828abf2-3a64-4794-9c1b-d5787cdae199",
  "http://rs.tdwg.org/dwc/terms/informationWithheld": null,
  "http://rs.tdwg.org/dwc/terms/recordNumber": "8588",
  "http://rs.tdwg.org/dwc/terms/month": "6",
  "http://rs.tdwg.org/dwc/terms/georeferencedBy": null,
  "http://rs.tdwg.org/dwc/terms/georeferenceVerificationStatus": null,
  "http://rs.tdwg.org/dwc/terms/island": null,
  "http://rs.tdwg.org/dwc/terms/coordinateUncertaintyInMeters": null,
  "http://rs.tdwg.org/dwc/terms/eventDate": "1999-06-09",
  "http://rs.tdwg.org/dwc/terms/municipality": null,
  "http://purl.org/dc/terms/references": "https://cch2.org/portal/collections/individual/index.php?occid=999496",
  "http://rs.tdwg.org/dwc/terms/year": "1999",
  "http://rs.tdwg.org/dwc/terms/taxonRank": "Species",
  "https://symbiota.org/terms/recordID": "ffd21dd4-478a-451a-bb12-cc7095afa7d6",
  "http://rs.tdwg.org/dwc/terms/associatedTaxa": null,
  "http://rs.tdwg.org/dwc/terms/disposition": null,
  "http://purl.org/dc/elements/1.1/rights": "http://creativecommons.org/licenses/by-nc/4.0/",
  "http://rs.tdwg.org/dwc/terms/locationID": null,
  "http://rs.tdwg.org/dwc/terms/habitat": null,
  "http://rs.tdwg.org/dwc/terms/fieldNumber": null,
  "http://rs.tdwg.org/dwc/terms/eventID": null,
  "http://rs.tdwg.org/dwc/terms/endDayOfYear": null,
  "http://rs.tdwg.org/dwc/terms/institutionCode": "RSA",
  "http://rs.tdwg.org/dwc/terms/typeStatus": null,
  "http://rs.tdwg.org/dwc/terms/collectionID": "3818e1d3-b6a4-11e8-b408-001a64db2964",
  "http://rs.tdwg.org/dwc/terms/locationRemarks": null,
  "http://rs.tdwg.org/dwc/terms/reproductiveCondition": "flowers & fruits",
  "http://purl.org/dc/terms/rightsHolder": null,
  "http://rs.tdwg.org/dwc/terms/lifeStage": null,
  "http://rs.tdwg.org/dwc/terms/sex": null,
  "https://symbiota.org/terms/recordEnteredBy": "LeRoy J. Gross; cataloged date: 2009-12-17",
  "http://rs.tdwg.org/dwc/terms/identifiedBy": "Carex Working Group",
  "http://rs.tdwg.org/dwc/terms/verbatimCoordinates": null,
  "http://rs.tdwg.org/dwc/terms/higherClassification": "Organism|Plantae|Viridiplantae|Streptophyta|Embryophyta|Tracheophyta|Spermatophytina|Magnoliopsida|Lilianae|Poales|Cyperaceae|Carex",
  "http://rs.tdwg.org/dwc/terms/georeferenceSources": null,
  "http://rs.tdwg.org/dwc/terms/waterBody": null,
  "http://rs.tdwg.org/dwc/terms/infraspecificEpithet": null,
  "http://rs.tdwg.org/dwc/terms/dynamicProperties": null,
  "http://rs.tdwg.org/dwc/terms/maximumElevationInMeters": null,
  "http://rs.tdwg.org/dwc/terms/verbatimTaxonRank": null,
  "http://rs.tdwg.org/dwc/terms/scientificNameAuthorship": "Mack.",
  "http://rs.tdwg.org/dwc/terms/stateProvince": "California",
  "http://rs.tdwg.org/dwc/terms/verbatimEventDate": null,
  "http://rs.tdwg.org/dwc/terms/decimalLatitude": null,
  "http://rs.tdwg.org/dwc/terms/establishmentMeans": null,
  "http://rs.tdwg.org/dwc/terms/locality": "Along CA Rt. 44, ca. 1 mile west of Viola, 13 miles east of Shingletown.",
  "http://rs.tdwg.org/dwc/terms/otherCatalogNumbers": "RSA accession: 637585",
  "http://rs.tdwg.org/dwc/terms/continent": null,
  "http://rs.tdwg.org/dwc/terms/georeferenceProtocol": null,
  "http://rs.tdwg.org/dwc/terms/class": "Magnoliopsida",
  "http://rs.tdwg.org/dwc/terms/identificationQualifier": null,
  "http://rs.tdwg.org/dwc/terms/scientificName": "Carex brainerdii",
  "http://rs.tdwg.org/dwc/terms/day": "9",
  "http://rs.tdwg.org/dwc/terms/order": "Poales",
  "http://rs.tdwg.org/dwc/terms/minimumElevationInMeters": "1372",
  "http://rs.tdwg.org/dwc/terms/specificEpithet": "brainerdii",
  "http://rs.tdwg.org/dwc/terms/taxonRemarks": null,
  "http://rs.tdwg.org/dwc/terms/associatedOccurrences": "herbariumSpecimenDuplicate: https://cch2.org/portal/collections/individual/index.php?guid=dbc2a8b9-6687-4005-ae96-51ab812dfe45 | herbariumSpecimenDuplicate: https://cch2.org/portal/collections/individual/index.php?guid=urn:catalog:CAS:BOT-BC:19648",
  "http://rs.tdwg.org/dwc/terms/decimalLongitude": null,
  "http://rs.tdwg.org/dwc/terms/basisOfRecord": "PreservedSpecimen",
  "http://rs.tdwg.org/dwc/terms/islandGroup": null,
  "http://rs.tdwg.org/dwc/terms/verbatimElevation": "4500ft.",
  "http://rs.tdwg.org/dwc/terms/individualCount": null,
  "http://purl.org/dc/terms/language": null,
  "http://purl.org/dc/terms/accessRights": null,
  "http://rs.tdwg.org/dwc/terms/startDayOfYear": "160",
  "http://rs.tdwg.org/dwc/terms/country": "United States",
  "http://rs.tdwg.org/dwc/terms/catalogNumber": null,
  "http://rs.tdwg.org/dwc/terms/georeferenceRemarks": null,
  "http://rs.tdwg.org/dwc/terms/genus": "Carex",
  "http://rs.tdwg.org/dwc/terms/associatedSequences": null,
  "http://rs.tdwg.org/dwc/terms/kingdom": "Plantae",
  "http://rs.tdwg.org/dwc/terms/dataGeneralizations": null,
  "http://rs.tdwg.org/dwc/terms/preparations": "herbarium sheet",
  "http://rs.tdwg.org/dwc/terms/collectionCode": "RSA",
  "http://rs.tdwg.org/dwc/terms/recordedBy": "Michael A. Vincent",
  "http://rs.tdwg.org/dwc/terms/maximumDepthInMeters": null,
  "http://rs.tdwg.org/dwc/terms/family": "Cyperaceae",
  "http://rs.tdwg.org/dwc/terms/identificationRemarks": null,
  "http://rs.tdwg.org/dwc/terms/identificationReferences": null,
  "http://rs.tdwg.org/dwc/terms/occurrenceRemarks": "Disturbed (logged) evergreen (pine, fir, cedar, Douglas fir) forest.Common in conifer forest. In colonies to 2 feet wide.",
  "http://rs.tdwg.org/dwc/terms/ownerInstitutionCode": null,
  "http://purl.org/dc/terms/modified": "2023-04-12 00:18:41",
  "http://rs.tdwg.org/dwc/terms/dateIdentified": "2012",
  "http://rs.tdwg.org/dwc/terms/phylum": "Tracheophyta",
  "http://rs.tdwg.org/dwc/terms/county": "Shasta",
  "http://rs.tdwg.org/dwc/terms/geodeticDatum": null,
  "http://rs.tdwg.org/dwc/terms/minimumDepthInMeters": null
}
```

suggesting that specimen with landing page at https://cch2.org/portal/collections/individual/index.php?occid=999496 is associated with the GenBank accessions decsribed by https://www.ncbi.nlm.nih.gov/nuccore/AY325485 and https://www.ncbi.nlm.nih.gov/nuccore/AY325460 . 

```json
{
  "accession": "AY325460",
  "http://www.w3.org/2000/01/rdf-schema#seeAlso": "https://ncbi.nlm.nih.gov/nuccore/AY325460",
  "definition": "Carex brainerdii external transcribed spacer 1f and 18S ribosomal RNA gene, partial sequence.",
  "organism": "Carex brainerdii",
  "specimen_voucher": "Vincent 8588 (RSA)",
  "db_xref": "taxon:247941",
  "http://www.w3.org/ns/prov#wasDerivedFrom": "line:gz:hash://sha256/909ca2f8d82e20ac64b2f24dea2c5e80ba14ca3eb73695d907d1d3ef2ed0d2d2!/L4355042-L4355087",
  "http://www.w3.org/1999/02/22-rdf-syntax-ns#type": "genbank-flatfile"
}
```

and 

```json
{
  "accession": "AY325485",
  "http://www.w3.org/2000/01/rdf-schema#seeAlso": "https://ncbi.nlm.nih.gov/nuccore/AY325485",
  "definition": "Carex brainerdii internal transcribed spacer 1, partial sequence; 5.8S ribosomal RNA gene, and internal transcribed spacer 2, complete sequence.",
  "organism": "Carex brainerdii",
  "specimen_voucher": "Vincent 8588 (RSA)",
  "db_xref": "taxon:247941",
  "http://www.w3.org/ns/prov#wasDerivedFrom": "line:gz:hash://sha256/909ca2f8d82e20ac64b2f24dea2c5e80ba14ca3eb73695d907d1d3ef2ed0d2d2!/L4356258-L4356306",
  "http://www.w3.org/1999/02/22-rdf-syntax-ns#type": "genbank-flatfile"
}
```
