# library(officer)
library(googlesheets4)
library(readr) # For writing the markdown file

# URL of the Google Sheet
sheet_url <- "https://docs.google.com/spreadsheets/d/19okp2ZOhmS9S2H33Mf6AHAH7lwTeB30vMikamjeKlCA/edit?gid=829220882#gid=829220882"

# Authenticate to access private sheets.
gs4_auth()

# Read the data from the sheet, skipping the first row so row 2 is the header
data <- read_sheet(sheet_url, col_names = TRUE, skip = 1)

# Definitions for mappings
dept_mapping <- c(
  "FISPPA" = "Dipartimento di Filosofia, sociologia, pedagogia e psicologia applicata",
  "DFA"    = "Dipartimento di Fisica e astronomia \"Galileo Galilei\"",
  "GEO"    = "Dipartimento di Geoscienze",
  "ICEA"   = "Dipartimento di Ingegneria civile, edile e ambientale",
  "DEI"    = "Dipartimento di Ingegneria dell'informazione",
  "DII"    = "Dipartimento di Ingegneria industriale",
  "DM"     = "Dipartimento di Matematica \"Tullio Levi-Civita\"",
  "DIMED"  = "Dipartimento di Medicina",
  "MAPS"   = "Dipartimento di Medicina animale, produzioni e salute",
  "DMM"    = "Dipartimento di Medicina molecolare",
  "DNS"    = "Dipartimento di Neuroscienze",
  "DPSS"   = "Dipartimento di Psicologia dello sviluppo e della socializzazione",
  "DPG"    = "Dipartimento di Psicologia generale",
  "SDB"    = "Dipartimento di Salute della donna e del bambino",
  "DSB"    = "Dipartimento di Scienze biomediche",
  "DCTV"   = "Dipartimento di Scienze cardio–toraco–vascolari e sanità pubblica",
  "DiSC"   = "Dipartimento di Scienze chimiche",
  "DISCOG" = "Dipartimento di Scienze chirurgiche oncologiche e gastroenterologiche",
  "DSF"    = "Dipartimento di Scienze del farmaco",
  "DSEA"   = "Dipartimento di Scienze economiche e aziendali \"Marco Fanno\"",
  "SPGI"   = "Dipartimento di Scienze politiche, giuridiche e studi internazionali",
  "STAT"   = "Dipartimento di Scienze statistiche",
  "DISSGeA" = "Dipartimento di Scienze storiche, geografiche e dell'Antichità",
  "DISLL"  = "Dipartimento di Studi linguistici e letterari",
  "DTG"    = "Dipartimento di Tecnica e gestione dei sistemi industriali",
  "TESAF"  = "Dipartimento di Territorio e sistemi agro-forestali"
)

quali_mapping <- c(
  "PA"   = "professore associato",
  "PO"   = "professore ordinario",
  "RTDA" = "ricercatore a tempo determinato A",
  "RTDB" = "ricercatore a tempo determinato B",
  "RU"   = "ricercatore unico",
  "PTA"  = "personale tecnico",
  "RTT"  = "ricercatore tenure track",
  "PD"   = "professoressa straordinaria a tempo definito",
  "RR"   = "contrattista di ricerca"
)

# Initialize markdown content with the title
md_content <- "# Database Ricercatori Univeristà di Padova\n\n"

# Print joined content for each row
cols_of_interest <- c("Cognome", "Nome", "Dept", "QualiID", "Keywords Scopus - Max 15", "Keywords manually curated", "Is_Padova", "Publications", "Citations", "e-mail")

# Check if columns exist in data to avoid errors
missing_cols <- setdiff(cols_of_interest, names(data))
if (length(missing_cols) > 0) {
  warning(paste("Columns not found:", paste(missing_cols, collapse = ", ")))
}

# Iterate and process
for (i in 1:nrow(data)) {
  # Extract values for the current row
  row_vals <- data[i, intersect(cols_of_interest, names(data))]
  
  if (all(is.na(row_vals) | row_vals == "")) {
    break 
  }
  
  # Helper to get values with safe defaults
  get_val <- function(col, default = "") {
    if (!col %in% names(data)) return(default)
    val <- data[[col]][[i]]
    
    # Check for physical NULL or empty elements
    if (is.null(val) || length(val) == 0) return(default)
    
    # Convert to character and trim for robust string checking
    char_val <- trimws(as.character(val))
    
    # Check for R's special NA/NaN OR the literal strings "NA", "NULL", "NaN", ""
    if (is.na(val) || char_val == "NA" || char_val == "NULL" || char_val == "NaN" || char_val == "") {
      return(default)
    }
    
    return(char_val)
  }
  
  # Skip rows where Is_Padova is "No"
  if (get_val("Is_Padova") == "No") {
    next
  }
  
  cognome    <- get_val("Cognome")
  nome       <- get_val("Nome")
  dept_code  <- get_val("Dept")
  quali_code <- get_val("QualiID")
  kw         <- get_val("Keywords Scopus - Max 15", "dato non disponibile")
  kw_manual  <- get_val("Keywords manually curated", "dato non disponibile")
  pubs       <- get_val("Publications", "dato non disponibile")
  cites      <- get_val("Citations", "dato non disponibile")
  email      <- get_val("e-mail")
  
  # Apply mappings
  dept_full  <- if (dept_code %in% names(dept_mapping)) dept_mapping[[dept_code]] else dept_code
  quali_full <- if (quali_code %in% names(quali_mapping)) quali_mapping[[quali_code]] else quali_code
  
  researcher_md <- sprintf(
    "## Ricercatore: %s %s
- **Dipartimento:** %s
- **Email:** %s
- **Qualifica:** %s
- **Keyword di ricerca in ordine di preferenza:** %s
- **Keyword di ricerca curate manualmente:** %s
- **Pubblicazioni:** %s
- **Citazioni:** %s
 
**Profilo Professionale:**
Il ricercatore è %s al %s, ha pubblicato %s papers con %s citazioni. 
I suoi interessi di ricerca da Scopus in ordine di preferenza sono: %s.
I suoi interessi di ricerca curati manualmente sono: %s.
Per contatti accademici e collaborazioni di ricerca, fare riferimento all'indirizzo %s.

---
", 
    cognome, nome, dept_full, email, quali_full, kw, kw_manual, pubs, cites,
    quali_full, dept_full, pubs, cites, kw, kw_manual, email)
  
  # Append to md_content
  md_content <- paste0(md_content, researcher_md, "\n")
  
  # Print name for feedback
  cat("Processed:", cognome, nome, "\n")
}

# Save the final .md file
output_file <- "./20260325_ResearchesDBtoMD.md"
write_file(md_content, output_file)
cat(paste("\nDone! Markdown file saved to:", output_file, "\n"))