# SNPPIT

**SNPPIT** - (SNP) (P)rogram for (I)ntergenerational (T)agging

A fast and accurate C program for parentage analysis using SNP (Single Nucleotide Polymorphism) data. SNPPIT performs statistical analyses to identify parent-offspring relationships and trio assignments using bi-allelic genetic markers.

## Key Features

- Fast parentage assignment using SNP data
- Forward-backward algorithm for statistical inference
- Trio mixture modeling
- False discovery rate control
- Multi-platform support (Linux, macOS, Windows)
- Docker containerization for reproducible analyses

## Quick Start

```bash
# Show help
./snppit-Linux --help

# Test with example data
./snppit-Linux -f ExampleData/ExampleDataFile1.txt

# Validate your data format
./snppit-Linux -f your_data.txt --dry-run
```

## Documentation

Full documentation is found in `doc/snppit_doc.pdf`. An example dataset is included in the `ExampleData` directory.

## Input Data Requirements

**CRITICAL: SNPPIT only supports bi-allelic SNP markers encoded as integers.**

### Supported Data Format
- **Alleles**: Must be encoded as integers (e.g., 1, 2)
- **Missing data**: Represented as `* *`
- **Loci**: Maximum of 2 alleles per locus (bi-allelic only)
- **Individual data**: Tab-separated format with metadata and genotypes

### Unsupported Formats
- ❌ Character alleles (A, T, C, G)
- ❌ Haplotype strings ("ATCG")
- ❌ Multi-allelic markers (>2 alleles per locus)
- ❌ Mixed integer/character formats

### Complete File Structure

SNPPIT input files have three main sections:

#### 1. Header Section (Configuration)
```
NUMLOCI 96
MISSING_ALLELE *
POPCOLUMN_SEX
POPCOLUMN_REPRO_YEARS  
POPCOLUMN_SPAWN_GROUP
OFFSPRINGCOLUMN_SAMPLE_YEAR
OFFSPRINGCOLUMN_AGE_AT_SAMPLING
Locus_1 0.005
Locus_2 0.005
...
```

#### 2. POP Sections (Potential Parents)
```
POP BreedingPool_2019
Female_001  F  4  1  1 2  2 2  1 1  2 1  ...
Male_001    M  4  1  2 2  1 2  2 1  1 2  ...

POP BreedingPool_2020
Female_002  F  3  2  2 1  1 2  2 2  1 1  ...
```

**POP Format:** `IndividualID Sex Age SpawnGroup GenotypeData`
- Contains individuals who could be parents
- Organized by breeding populations
- Include reproductive metadata

#### 3. OFFSPRING Sections (Need Parentage Assignment)
```
OFFSPRING Juveniles_2021 BreedingPool_2019,BreedingPool_2020
Juvenile_001  2021  1  1 2  2 2  1 2  2 1  ...
Juvenile_002  2021  1  2 1  1 1  2 2  1 2  ...

OFFSPRING WildSample_2022 ?
Wild_001  2022  2  2 2  1 2  1 1  2 1  ...
```

**OFFSPRING Format:** `IndividualID SampleYear Age GenotypeData`
- Contains individuals needing parent identification
- Header specifies which POPs contain potential parents:
  - `?` = any POP could contain parents
  - `Pop1,Pop2` = only those specific populations
- Include sampling metadata

## Source Code and Binaries

Source code is in the `src` directory. Pre-compiled binaries are available:
- `snppit-Linux` (Linux)
- `snppit-Darwin` (macOS) 
- `snppit-windows.exe` (Windows)

### Recent Updates
New options for excluding parent pairs based on log-likelihood ratios and limiting non-excluded parent pairs. See: [http://eriqande.github.io/snppit/logl-and-rank-thresholding.nb.html](http://eriqande.github.io/snppit/logl-and-rank-thresholding.nb.html)

## Installation

### Option 1: Download Repository
```bash
git clone https://github.com/eriqande/snppit.git
cd snppit
```

Or download zip from: https://github.com/eriqande/snppit/archive/master.zip

### Option 2: Docker (Recommended)
```bash
# Pull and run latest version
docker run --rm bnguyen29/snppit:latest

# Run with your data
docker run --rm -v $(pwd):/data bnguyen29/snppit:latest -f your_data.txt
```

### Option 3: Compile from Source
```bash
git clone https://github.com/eriqande/snppit.git
cd snppit
./Compile_snppit.sh
```


## Usage Instructions

### Command Line Syntax
```bash
./snppit-[platform] -f datafile.txt [options]
```

### Essential Options
- `-f FILE` - Path to input data file (required)
- `--dry-run` - Validate data format without running analysis
- `--help` - Show brief help
- `--help-full` - Show detailed help with all options
- `--max-par-miss N` - Maximum missing loci for parents (default: 10)
- `--mi-fnr RATE` - False negative rate threshold (default: 0.005)

### Platform-Specific Quick Start

**Warning:** Pre-compiled binaries may not reflect the latest code. For latest features, compile from source.

To get started quickly:

#### Windows

**Note:** Use `snppit-windows.exe` (natively compiled) for best performance.

1. Copy `snppit-windows.exe` and `ExampleData/ExampleDataFile1.txt` to your Desktop
2. Open Command Prompt (Start → All Programs → Accessories)
3. Navigate to Desktop: `cd Desktop`
4. Run: `snppit-windows.exe -f ExampleDataFile1.txt`

#### macOS

1. Copy `snppit-Darwin` and `ExampleData/ExampleDataFile1.txt` to your Desktop
2. Open Terminal (Applications → Utilities → Terminal)
3. Navigate to Desktop: `cd Desktop`
4. Run: `./snppit-Darwin -f ExampleDataFile1.txt`

#### Linux

1. Copy `snppit-Linux` and example data to your working directory
2. Open terminal
3. Run: `./snppit-Linux -f ExampleDataFile1.txt`

For your own data, replace `ExampleDataFile1.txt` with your filename.


## Output Files

SNPPIT generates multiple output files with the prefix `snppit_output_`:
- `snppit_output_BasicDataSummary.txt` - Summary statistics
- `snppit_output_PopSizesAnPiVectors.txt` - Population parameters
- Additional analysis-specific files

## Data File Organization

### Key Concepts

**POP Sections** define potential parent pools:
- Each POP represents a breeding population or cohort
- Contains individuals who could be parents
- Organized by reproductive groups and timing

**OFFSPRING Sections** define individuals needing parentage:
- Each OFFSPRING represents a sampling collection
- Specifies which POP sections contain candidate parents
- Allows flexible parent-offspring relationships

### Parent Pool Assignment

```bash
# Offspring can have parents from any POP
OFFSPRING MySample ?

# Offspring can only have parents from specific POPs  
OFFSPRING MySample ParentPool_A,ParentPool_B

# Multiple offspring collections with different parent restrictions
OFFSPRING EarlySpawners Pool_Early
OFFSPRING LateSpawners Pool_Late
OFFSPRING MixedSample Pool_Early,Pool_Late
```

## Data Validation

**Always validate your data before running the full analysis:**

```bash
# Check data format and structure
./snppit-Linux -f your_data.txt --dry-run
```

Common issues:
- Non-integer alleles will be silently converted to 0
- More than 2 alleles per locus causes fatal error
- Missing partial genotypes get warnings
- Incorrect POP/OFFSPRING section structure
- Mismatched column counts between header and data

## Performance Notes

Native compilation provides best performance. Virtual machines may run 20x slower than native execution.

For complete options: `./snppit-Linux --help-full`

## Building from Source

### Compilation
```bash
git clone https://github.com/eriqande/snppit.git
cd snppit
./Compile_snppit.sh
```

This creates platform-specific binaries:
- `snppit-Darwin` (macOS)
- `snppit-Linux` (Linux)
- `snppit-windows.exe` (Windows, cross-compiled)

**Note:** Linux compilation may show fscanf warnings - these are non-fatal and can be ignored.

### Docker Build
```bash
# Local build
docker build -t snppit .

# Multi-platform build
docker buildx build --platform linux/amd64,linux/arm64 -t snppit:latest .
```


## Testing

Test suite validates program functionality across platforms:

```bash
# Run all tests
cd test
./run_all_tests.sh

# Run single test
cd test/specific_test_dir
../run_test.sh

# Update test results (after code changes)
./run_all_tests.sh -o
```

Tests compare output against stored reference results and check cross-platform consistency. Some tests may show different individual orderings between Linux and macOS, which is expected behavior.

### Docker Testing
```bash
docker-compose run --rm snppit-test
```


## Troubleshooting

### Common Issues

**Program crashes with "more than 2 alleles" error:**
- SNPPIT only supports bi-allelic markers
- Check for mixed integer/character alleles
- Ensure all alleles are encoded as integers

**Character alleles (A,T,C,G) in data:**
- Convert to integer encoding before analysis
- Example: A=1, T=2 or other integer mapping

**Performance issues:**
- Use native binaries rather than virtualized environments
- Consider Docker for consistent performance
- Limit parent pairs with `--max-par-pair` if needed

## Support and Documentation

- Full documentation: `doc/snppit_doc.pdf`
- Command help: `./snppit-Linux --help-full`
- Example data: `ExampleData/ExampleDataFile1.txt`
- Issues: [GitHub Issues](https://github.com/eriqande/snppit/issues)

## Funding and Contributors

This work was funded by the Pacific Salmon Commission Chinook Technical Committee Letter of Agreement.

**Development Team:**
- Eric C. Anderson (eric.anderson@noaa.gov)
- Veronica Mayorga

**Acknowledgments:**
- Matt Campbell (program name suggestion)
- Jon Hess at CRITFC (Windows compilation)

## License

See repository for license information.

