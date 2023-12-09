# Introduction
This repository corresponds to our final project for Computational Genomics: Sequences. The team consists of Tad Berkery, Xinlei (Lily) Chen, Richard Hu, and Yuseong (Nick) Oh. We outline in our report our review of prior work, methodologies, and results. What follows are some auxiliary instructions to complement the report on how to run our code with the goal of aiding with reproducibility. If you have any issues on this front, please reach out and let us know.

# Protein Fold Clustering
A key source of inspiration for this project is code that generates a sequence of numbers indicating clusters representing protein folds. This code is written in MatLab and is primarily contained in the "msm_code_Richard", "clustering_code", "Lagnevin_clustering" and "Langevin dynamics code" subfolders. This code is notably outside the scope of our project and comes from a biophysics class taken by Richard and Lily. All of this code comes from Dr. Maggie Johnson's class "Modeling the Living Cell" but is written by Richard and Lily as part of assignments for her class. Richard and Lily obtained permission (documented over email) from Dr. Johnson to use this code for this project. A useful distinguishing factor of this code relative to the code we designed for this project (overview of this below) is that the code from Dr. Johnson's class is in Matlab. This code is what produced the file text.txt within the BWT_HMM subfolder, which is a sequence of 1,000,000 numbers representing cluster assignments at each position. We included this code for comprehensiveness, but, in relation to reproducing this project, the code associated with our deliverables begins at the level of treating this sequence file as already existent and working from there. We then created the "generate_sequence" directory and code inside it to provide a mechanism for generating additional such sequences.

# Several Algorithms
With the above context, we then proceeded to implement several architectures, headlined by the Burrows-Wheeler-Transform Hidden-Markov-Model ("BWT-HMM" folder), Burrows-Wheeler-Transform Hidden-Markov-Model with merging ("BWT-HMM_Merging" folder), and MLSE Viterbi, which is spread across the "Compress_sequence" and "main_method" folders. The best way to see our underlying implementations is to look at the code in these directories. The code in these directories is a mix of code that can be executed by running a given script and code that works together across many scripts.

# Benchmarking
A key deliverable for our project beyond any architecture implementation itself is a mini suite of software for benchmarking performance in terms of time and space associated with different algorithms when used on different sequences. This software is built out in the "benchmark" subdirectory, which contains Python scripts that methodically run all of the algorithm implementations referenced above in a very methodical, trackable manner. The most important file, which is executed to obtain the benchmarking data, is the `profile.py` file. Note that the general structure of this file at a high-level is that it imports functions for each architecture of interest that take only the sequence to run the architecture on as its only argument, wraps these functions in wrapper functions critically annotated with `@profile` to enable use of the `memory_profiler` Python package (which you will need to install), and calls the function for each architecture under each sequence of interest, where sequences of interest are themselves obtained as the value returned by calling various functions. This structure is intentionally very formal to try to make it easy to add different architectures and sequences to be benchmarked. 

Once the proper architecture functions and sequence functions are specified and variables like `ds_functions`, `sample_functions`, `sample_function_descriptors`, `data_structure_descriptors`, and `continuation` are properly specified (see the detailed commentary in-line with the code on how to do this), the `profile.py` Python script can be run with a command like the following: `python ./benchmark/profile.py space_complexity_info_updated.txt benchmarking_results_updated.csv > space_complexity_info_updated.txt`. Note that `continuation` is a boolean that lets you indicate whether you want to add onto existing benchmarking data or start fresh in relation to the *runtime* results (but only in relation to the *runtime* results, *not* the *memory usage* results... more on why shortly). If `continuation` is set to true, note that a CSV file of the name of the second command line argument (`benchmarking_results_updated.csv` in our example here) must both (1) exist and (2) contain data in a CSV format with these columns and column names: "data_structure", "sample", "iteration", "user", "runtime". 

*Remark*: For all commands listed in this README, we assume that you are executing the command from the root of this repository (i.e. not from within any subdirectory).

Note that `num_iterations` is set to 1 even though we mention that we benchmarked across 25 iterations per arhitecture-sequence combination. We do not recommend adjusting `num_iterations`. Initially, we set it to e.g. 25 and used it as the mechanism to benchmark each architecture many times. However, we found that the memory usage and run time generally monotonically increased as the number of iterations increased, almost certainly because despite our requests to Python and best efforts variables were not always being totally garbage collected upon going out of scope in terms of logic. This obviously introduced major bias, so we overcame this issue by instead having each execution of the Python script involve `num_iterations = 1` and accomplished the effect of 25 iterations by calling the `profile.py` script 25 separate times (enabling us to have everything go out of scope between iterations by nature of the script terminating at the command line each time). This solved the earlier issue. We created the bash script `run.sh` (in the root directory, not any subdirectory) to call `profile.py` for the appropriate number of iterations. It is a very simple script but plays a pivotal role in the benchmarking.

To execute `run.sh`, you will need to be in an appropriate environment for running bash/shell scripts. Tad designed the entire benchmarking suite and is a Windows PC user. For him, typing the command `./run.sh` in a generic windows terminal did not result in an error but did not result in the script's execution because this was not a valid place designed to run this type of script. He installed Git Bash (if needed, see a tutorial on how to this [here](https://www.educative.io/answers/how-to-install-git-bash-in-windows)). He would open Git Bash, navigate to the appropriate directory (for Tad, ths involved going `cd Documents/protein-fold-pipeline`) and would then execute `./run.sh` and have the script run successfully.

Note that in `profile.py` (which is executed by `run.sh`) the runtime benchmarking is completed by using the `time` library and noting the elapsed time for each architecture-sequence combination in a pandas dataframe that becomes, in the case of the current scripts, `benchmarking_results_updated.csv`. The tracking of memory usage is performed via the `@profile` annotations above the `bwt_hmm_with_space_annotation`, `make_proposals_mlse`, and `bwt_hmm_with_merging_strategy` wrapper functions, which invoke the `memory_profiler` library. `memory_profiler` prints memory usage as if it came out of print statements in a way we cannot control, which will result in the memory usage estimates emerging in a pretty-to-the-eye but rather complicated-from-a-coding-perspective format and will not automatically be stored in `space_complexity_info_updated.txt`. Once `run.sh` finishes executing the Git Bash window, copy all of the output it displayed manually and paste it in `space_complexity_info_updated.txt`. Then, in the command line (either in Git Bash or in a normal terminal window, either is fine), run `python benchmark/parse_memory_usage_report.py space_complexity_info_updated.txt`. The `parse_memory_usage_report.py` script is a complex script that pulls the memory usage estimates out of this elaborate format printed by the `memory_profiler` package. Sometimes, potentially depending on the size of the Git Bash window on the screen when `run.sh` was executed, the `parse_memory_usage_report.py` function will throw an error due to new lines being inserted after the `========` lines in the print output. If this happens, try the same command but use `parse_memory_usage_report_alternate.py` instead (which has modifications to handle these ad hoc new lines).

At this point, the memory usage is in the `memory_usage_updated.csv` file in an interpetable format and the runtime data is in the `benchmarking_results_updated.csv` file that was produced directly when `profile.py` was executed by `run.sh`. We have our data and can extract analytics of interest and produce visualizations. Because of the convenience of the `ggplot2` library, this is done in R. `visualize_runtime.R` and `visualize_space.R` are similar scripts that produce comparable visualizations based on the memory usage and runtime data, respectively. `analytics.R` works with the data to pull out some key metrics and includes code to conduct statistical tests on our benchmarking data. The visuals and metrics used in our report in the Results section come from these R scripts.

# Miscellaneous
* For the code in the "BWT_HMM" and "BWT_HMM_Merging" directories, much of the Python code (such as `bwthmm.py`) relies on the [`hmmlearn`](https://pypi.org/project/hmmlearn/) package. This package proved to be quite difficult to install and delicate on several occasions, perhaps likely because it is self-described by its creators as being "under limited-maintenance mode." If you have issues with it, please ensure that you have Python >= 3.6, NumPy >= 1.10, and scikit-learn >= 0.16. Of note, `hmmlearn` is a direct offshoot of the origin [scikit-learn hidden markov model package](https://scikit-learn.sourceforge.net/stable/modules/hmm.html), which is now deprecated "due to it no longer matching the scope and the API of the project" and "scheduled for removal in the 0.17 release of the project". scikit-learn recommends using hmmlearn as we did, and we did not want our code to depend on a package set to soon go out of existence, so we used hmmlearn and endured its often painful installation difficulties. If this poses issues on a Mac, try [here](https://github.com/hmmlearn/hmmlearn/issues/475). If this poses issues on a PC, try [here](https://stackoverflow.com/questions/51002441/unable-to-install-hmmlearn-in-python-3).
* The "kmerindex" directory contains code that we used at times to contextualize how different architectures fare in relation to a generic, typical kmer index. We used this in some benchmarking analyses performed in the "experimentation" branch of the repo but chose to stop shot of including all of it in "main".
* In general here, "architecture" (typically in the README) and "data structure" (typically in the code) are used relatively interchangeably and generally refer to the same thing.
* There is an "experimentation" branch we intentionally have not merged with "main".
  
# List of Python Package Dependencies
(beyond standard packages)
* `pandas`
* `numpy`
* `memory_profiler`
* `hmmlearn`
* `random`
* `copy`
* `matplotlib`
* `bisect`
* `networkx`
* `collections`

# List of R Package Dependencies
(beyond standard packages)
* `tidyverse`
* `ggplot2`
* `gridExtra`
