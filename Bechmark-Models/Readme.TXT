Each folder for the individual benchmark models contains the following files/folders:


1) Folder "Data" 
This folder contains the experimental data sets. 

Each file contains two sheets, one for the experimental data and one for the model response for the same experimental conditions (i.e. for the same observables, inputs and time points). These model responses can be used to check proper implementation. For each experimental data point, a standard deviation specifying the magnitude of the measurement error is provided. Either this standard deviation is available from the experiment (_ExpError) or, otherwise, it is provided as an estimate from the error model (_std).


2) Folder "Model" 
This folder contains the model equations which hold for the respective data set. 

Since every data set is generated for specific experimental conditions (e.g. for a specific treatment, for wild-type/overexperession setting etc), the equations differ between the data sets. In the "Model" folder, we provide the general model equations which hold for all data sets but might contain dummy variables indicating experimental conditions. In addition we provide  equations after dataset-specific substitutions, i.e. after proper replacements. After these substituitons only parameters which are specified in General_info.xlsx" remain and the equations can be directly used to simulate the model for the respective dataset.


3) Folder "SBML"
This folder contains the model definition in the SBML format.


4) "General_info.xlsx" 
This file contains a summary for the model. For simulating a model, only the parameters are required from this file. In addition, the dataset-specific substitutions are shown/summarized. These substitutions, however, were already executed in the data-specific model files.

