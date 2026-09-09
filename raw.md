# Konwersacja: lokalny pipeline Markdown → Typst → PDF dla CV

> Eksport rozmowy do dalszej analizy i pracy w Cursorze.

## Użytkownik

Czy istnieje narzędzie które umożliwia przerobienie CV zrobionego w
Markdown w ładną wersję PDF, gdzie dane są dobrze umiejscowione i
strukturowane?

## Asystent

Tak. Jest kilka bardzo dobrych opcji --- wybór zależy głównie od tego,
czy chcesz automatycznie renderować Markdown, czy mieć większą kontrolę
nad wyglądem CV.

Najbardziej sensowne rozwiązania:

-   **RenderCV** --- narzędzie ukierunkowane na CV, z uporządkowanymi
    danymi i generowaniem profesjonalnego PDF.
-   **Typst** --- dobre rozwiązanie, jeśli zależy Ci na estetycznym
    PDF-ie i pełnej kontroli nad layoutem.
-   **Pandoc + LaTeX** --- klasyczny pipeline Markdown → Pandoc → LaTeX
    → PDF.
-   **Quarto** --- również potrafi generować PDF z Markdown, choć jest
    bardziej nastawione na raporty i dokumentację.

Jeżeli CV jest już w Markdown, możliwe jest przygotowanie eleganckiego
PDF z dwukolumnowym layoutem, nagłówkiem z danymi kontaktowymi,
wyróżnionym doświadczeniem i projektami oraz typografią przyjazną ATS.

## Użytkownik

Chodzi mi o to, żeby to było narzędzie lokalne, nie webowe, uruchamiane
z konsoli w mac OS X.

## Asystent

W takim przypadku najlepszym kierunkiem są narzędzia CLI działające
całkowicie lokalnie na macOS.

### RenderCV

Przykładowa instalacja i użycie:

``` bash
pipx install rendercv
rendercv render cv.yaml
```

### Pandoc + LaTeX

Jeśli Markdown ma pozostać bezpośrednim źródłem:

``` bash
brew install pandoc
brew install --cask basictex
```

Generowanie PDF:

``` bash
pandoc cv.md -o cv.pdf --pdf-engine=xelatex
```

Z własnym template'em:

``` bash
pandoc cv.md \
  --template=cv-template.tex \
  --pdf-engine=xelatex \
  -o cv.pdf
```

### Typst CLI

Nowocześniejsza alternatywa dla LaTeX-a:

``` bash
brew install typst
typst compile cv.typ cv.pdf
```

Zaproponowany pipeline:

``` text
cv.md
   ↓
Pandoc
   ↓
template.typ
   ↓
Typst
   ↓
cv.pdf
```

Całość może być opakowana w `Makefile`, aby generowanie sprowadzić do:

``` bash
make cv
```

## Użytkownik

Tak, jednoznacznie chciałbym zachować Markdown jako single source of
truth, podpiąć go do git repo żeby mieć wersjonowanie a do tego różne
wersje CV, być może nawet parametryzowane do generacji skryptem. Podoba
mi się wersja z typst i kompilacją ala make cv z parametrami, że pod
"project managera" masz jeden wariant, pod "developera ruby" inny, pod
"analityka ze znajomością python" etc. A layouty mogą być osobno właśnie
jako typ. Może istnieją jakieś gotowce z tych layoutów, żeby nie
wymyślać koło na nowo? Da się zobaczyć coś w tym stylu?

## Asystent

Tak --- ten model ma dużo sensu: Markdown jako źródło, osobne
profile/overrides, osobne layouty i jedna komenda build.

Najciekawszy kierunek to:

**Markdown jako kanoniczne źródło → skrypt budujący wariant → Typst jako
renderer/layout.**

Do tego osobne profile typu `pm`, `ruby`, `python-analyst`, a layout
wybierany parametrem.

### Proponowana struktura repozytorium

``` text
cv/
├── cv.md
├── profiles/
│   ├── developer-ruby.yaml
│   ├── project-manager.yaml
│   └── python-analyst.yaml
├── layouts/
│   ├── modern.typ
│   ├── compact.typ
│   └── two-column.typ
├── scripts/
│   └── build.py
├── build/
├── Makefile
└── README.md
```

`cv.md` zawiera całą historię zawodową:

``` markdown
# Experience

## Foo Corp
### Senior Software Engineer
2019–2024

- Designed distributed Ruby services.
- Led migration from Rails monolith.
- Coordinated roadmap with product and stakeholders.
- Built Python tooling for analytics.
- Mentored 6 engineers.
```

Profil określa, co eksponować:

``` yaml
name: ruby

headline: Senior Ruby Developer

include:
  skills:
    - ruby
    - rails
    - postgres
    - distributed-systems

priorities:
  - backend
  - architecture
  - ruby
  - mentoring

exclude:
  - project-management-detail

max_pages: 2
layout: modern
```

Budowanie wariantu:

``` bash
make cv PROFILE=ruby
```

Rezultat:

``` text
build/cv-ruby.pdf
```

Inny wariant:

``` bash
make cv PROFILE=project-manager LAYOUT=two-column
```

### Podział odpowiedzialności

Logiki wariantów nie warto umieszczać w całości w Typst. Typst powinien
przede wszystkim odpowiadać za rendering.

Pipeline może wyglądać tak:

``` text
cv.md
  │
  ├── parse Markdown
  │
profile.yaml
  │
  ▼
build.py
  │
  ▼
generated.typ / generated.json
  │
layout.typ
  │
  ▼
Typst
  │
  ▼
cv-ruby.pdf
```

Jeszcze czystsza wersja:

``` text
cv.md
    ↓ Python
resume.json
    ↓
Typst template
    ↓
PDF
```

Typst może czytać JSON:

``` typst
#let cv = json("build/resume.json")

#cv.name

#for job in cv.experience {
  job.title
  job.company
}
```

Docelowy podział:

``` text
Markdown     → content
YAML profile → selection
JSON         → intermediate representation
Typst        → presentation
Makefile     → interface
Git          → versioning
```

Możliwe komendy:

``` bash
make cv-ruby
make cv-pm
make cv-python

make cv PROFILE=ruby LAYOUT=compact
make cv PROFILE=ruby LAYOUT=modern
make cv PROFILE=pm LAYOUT=modern
```

Alternatywnie własne CLI:

``` bash
./cv build ruby
./cv build pm
./cv build python-analyst

./cv build ruby --layout compact
./cv build ruby --pages 1
```

### Tagi i automatyczna selekcja treści

Elementy Markdown mogą być oznaczane metadanymi:

``` markdown
- Led migration of Rails monolith.
  <!-- tags: ruby,rails,architecture -->

- Coordinated roadmap across 4 teams.
  <!-- tags: management,stakeholders,planning -->

- Created Python analytics pipeline.
  <!-- tags: python,data,analytics -->
```

Profil może następnie podbijać wybrane tagi:

``` yaml
ruby:
  boost:
    - ruby
    - rails
    - architecture

python-analyst:
  boost:
    - python
    - data
    - analytics
```

Dzięki temu system może automatycznie wybierać najbardziej odpowiednie
bullet pointy.

### Idea architektoniczna

W praktyce powstaje **„CV as code" / „CV compiler"**:

-   jedno źródło prawdy w Markdown,
-   Git jako historia zmian,
-   profile stanowisk jako konfiguracja,
-   niezależne layouty Typst,
-   pośredni model danych JSON,
-   deterministyczny build z CLI/Makefile,
-   możliwość generowania wielu wariantów CV z tego samego źródła.

### Wspomniane gotowe layouty / projekty

W rozmowie pojawiły się jako punkty odniesienia:

-   `modern-typst-resume`
-   `basic-resume`
-   `neat-cv`
-   `alta-typst`
-   kolekcje gotowych template'ów Typst
-   `ATS Safe Resume` jako przykład architektury z kanonicznym modelem
    danych i rendererami

Rekomendowany kierunek to rozpoczęcie od prostego template'u
ATS-friendly i potraktowanie go jako wymiennej warstwy prezentacji,
zamiast wiązania danych CV z konkretnym layoutem.

------------------------------------------------------------------------

## Kierunek dalszej pracy w Cursorze

Najbardziej naturalnym następnym krokiem jest stworzenie działającego
MVP repozytorium:

1.  zdefiniowanie schematu `cv.md`,
2.  zdefiniowanie `profiles/*.yaml`,
3.  parser Markdown → kanoniczny model danych,
4.  zapis modelu do `build/resume.json`,
5.  pierwszy template Typst,
6.  `Makefile`,
7.  komendy `make cv PROFILE=... LAYOUT=...`,
8.  walidacja danych i profili,
9.  opcjonalny mechanizm tagowania/rankingu bullet pointów,
10. testy zapewniające deterministyczny build.

### Docelowa właściwość systemu

Treść CV powinna pozostać niezależna od sposobu prezentacji:

``` text
                ┌─ profile: ruby ─────────┐
                │                         ▼
cv.md ── parser ── canonical model ── renderer ── PDF
                │                         ▲
                └─ profile: pm ───────────┤
                                          │
                                  layout: modern
                                  layout: compact
                                  layout: two-column
```

Dzięki temu zmiana layoutu nie wymaga modyfikowania treści, a utworzenie
nowej wersji CV powinno sprowadzać się przede wszystkim do dodania lub
zmiany profilu.
