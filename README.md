# ResearchersDB_TableToAI
R script to convert a spreadsheet containing researcher's data to .md file for RAG ingestion
- import table from google doc
- map QualiID e Dept acronyms to full text (hardcoded mapping)
- remove "Is_Padova" = No 
- it generates a file MD with the following format:
- 
# Database Ricercatori Univeristà di Padova

## Ricercatore: {Cognome} {Nome}
- **Dipartimento:** {Dept}
- **Email:** {e-mail}
- **Qualifica:** {QualiID}
- **Keyword di ricerca in ordine di preferenza:** {Keywords Scopus - Max 15}
- **Keyword di ricerca curate manualmente:** {Keywords manually curated}
- **Pubblicazioni:** {Publications}
- **Citazioni:** {Citations}
 
**Profilo Professionale:**
Il ricercatore è {QualiID} al {Dept}, ha pubblicato {Publications} papers con {Citations} citazioni.
I suoi interessi di ricerca in ordine di preferenza sono: {Keywords Scopus - Max 15}.
I suoi interessi di ricerca curati manualmente sono: {Keywords manually curated}.
Per contatti accademici e collaborazioni di ricerca, fare riferimento all'indirizzo {e-mail}.

---
