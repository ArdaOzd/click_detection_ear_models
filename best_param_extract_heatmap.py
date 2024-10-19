import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
import pandas as pd
from matplotlib.colors import ListedColormap
from matplotlib.colors import LinearSegmentedColormap



# Define the algorithm names and parameters

algorithms = {
    'AR model': ['Threshold gain', 'Order', 'Frame length'],
    1: '',
    'Matched filter': ['Threshold gain', 'Order', 'Frame length'],
    2: '',
    'Venčovský’s model': ['Threshold gain', 'First channel', 'Last channel'],
    3: '',
    'Lyon’s model': ['Threshold gain', 'Last channel'],
    4: '',
    'Wavelet transform': ['Threshold gain', 'Median filter length'],
    5: '',
    'DRNL model': ['Threshold gain', 'First channel'],
    6: '',
    'Seneff’s model': ['Threshold gain', 'Median filter length', 'Last channel'],
    7: '',
    'ERBlet transform': ['Threshold gain', 'Median filter length', 'First channel']
}




# Data taken from MATLAB( other_analysis.m last section)
drnl1 = [7, 7, 6, 7, 7, 13, 12, 6, 13, 13, 27, 18, 27, 27, 13, 27, 18, 10, 27, 11, 27, 11, 27, 37, 11]
drnl2 = [2, 2, 2, 2, 2, 4, 4, 2, 4, 4, 6, 5, 6, 6, 5, 6, 5, 5, 6, 5, 6, 5, 6, 7, 5]

erb1 = [18, 10, 1, 1, 10, 18, 10, 3, 5, 10, 42, 17, 45, 45, 10, 42, 48, 15, 14, 12, 23, 15, 14, 33, 15]
erb2 = [1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 11, 5, 1, 1, 1, 11, 1, 4, 6, 1, 1, 6, 10, 14, 4]
erb3 = [1, 7, 5, 5, 7, 1, 7, 5, 5, 7, 16, 7, 9, 9, 7, 16, 16, 9, 9, 9, 11, 9, 11, 12, 9]

lyon1 = [45, 38, 32, 41, 47, 32, 38, 32, 41, 47, 30, 38, 37, 38, 38, 36, 36, 31, 35, 38, 38, 34, 40, 40, 47]
lyon2 = [2, 1, 9, 12, 1, 9, 1, 9, 12, 1, 6, 1, 1, 1, 1, 5, 8, 11, 8, 1, 7, 9, 11, 11, 1]

senef1 = [20, 20, 10, 20, 20, 20, 20, 12, 20, 20, 21, 21, 21, 21, 21, 14, 13, 14, 28, 14, 12, 14, 14, 26, 14]
senef2 = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6, 1, 6, 1, 5, 5, 5, 6, 5, 6, 5, 5, 6, 5]
senef3 = [5, 5, 4, 5, 5, 5, 5, 4, 5, 5, 5, 6, 5, 6, 5, 6, 5, 7, 12, 7, 5, 6, 7, 12, 7]

ar1 = [31, 24, 20, 20, 1, 46, 46, 1, 30, 3, 11, 49, 12, 6, 45, 15, 17, 39, 37, 46, 17, 21, 22, 39, 23]
ar2 = [2, 2, 1, 1, 5, 4, 4, 4, 2, 27, 25, 7, 27, 30, 4, 1, 19, 3, 3, 4, 9, 8, 30, 14, 22]
ar3 = [11, 1, 1, 1, 1, 4, 5, 1, 1, 1, 1, 7, 1, 1, 1, 9, 2, 4, 1, 5, 4, 1, 13, 1, 3]

match1 = [16, 43, 29, 16, 16, 21, 22, 22, 46, 36, 31, 44, 22, 28, 27, 45, 45, 23, 46, 39, 45, 25, 33, 44, 43]
match2 = [1, 5, 2, 1, 1, 2, 19, 1, 3, 4, 3, 8, 1, 2, 3, 3, 3, 1, 3, 6, 20, 10, 22, 8, 17]
match3 = [2, 2, 1, 9, 9, 2, 1, 1, 1, 11, 1, 2, 1, 2, 2, 1, 1, 1, 1, 1, 1, 1, 4, 3, 1]


wave1 = [10, 13, 13, 12, 12, 12, 19, 17, 15, 19, 31, 20, 23, 31, 20, 24, 20, 17, 24, 20, 24, 20, 50, 28, 29]
wave2 = [3, 10, 10, 7, 10, 7, 15, 15, 14, 15, 23, 16, 31, 23, 16, 30, 16, 15, 30, 16, 30, 19, 21, 20, 27]

bm1 = [1, 1, 4, 5, 4, 6, 7, 18, 4, 6, 11, 25, 10, 47, 13, 14, 10, 44, 6, 44, 27, 37, 5, 14, 21]
bm2 = [1, 8, 6, 1, 2, 1, 1, 2, 2, 3, 5, 5, 4, 2, 5, 1, 4, 6, 3, 5, 1, 1, 1, 2, 1]
bm3 = [4, 8, 5, 1, 1, 1, 1, 3, 1, 2, 4, 6, 3, 6, 5, 2, 3, 8, 2, 7, 8, 8, 4, 4, 8]

drnl_ap = [
    1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 0.9875, 1.0000,
    0.9868, 0.9853, 0.9659, 0.9479, 0.9545, 0.9750, 0.9625, 0.9565,
    0.9400, 0.9432, 0.9545, 0.9534, 0.9286, 0.9244, 0.9000, 0.9300,
    0.9097
]

erb_ap = [
    1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000,
    1.0000, 1.0000, 0.9792, 0.9792, 0.9773, 0.9875, 0.9875, 0.9732,
    0.9719, 0.9678, 0.9683, 0.9886, 0.9459, 0.9643, 0.9379, 0.9589,
    0.9639
]

lyon_ap = [
    0.9688, 1.0000, 1.0000, 0.9844, 0.9821, 0.9833, 1.0000, 1.0000,
    0.9868, 0.9853, 0.9688, 0.9896, 0.9742, 0.9659, 0.9891, 0.9355,
    0.9605, 0.9432, 0.9326, 0.9658, 0.8884, 0.9344, 0.8920, 0.8947,
    0.9167
]

senef_ap = [
    1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000,
    1.0000, 1.0000, 0.9886, 0.9688, 0.9886, 0.9750, 0.9875, 0.9794,
    0.9605, 0.9678, 0.9659, 0.9886, 0.9442, 0.9444, 0.9256, 0.9519,
    0.9580
]

ar_ap = [
    0.7656, 0.7778, 0.7656, 0.7656, -0.1429, 0.7632, 0.7750, -0.1447,
    0.7632, -0.1129, 0.0154, 0.8229, 0.0154, -0.0888, 0.7625, 0.7717,
    0.1667, 0.7708, 0.7841, 0.7727, 0.9539, 0.9364, 0.9237, 0.9400,
    0.9444
]

match_ap = [
    0.1134, 0.8056, 0.7656, -0.0023, 0.0613, 0.2333, -0.0576, 0.7632,
    0.7632, 0.7941, 0.7841, 0.8125, 0.7614, 0.0129, 0.7750, 0.7609,
    0.7700, 0.7604, 0.7614, 0.7727, 0.9019, 0.9036, 0.8757, 0.9200,
    0.9074
]

wave_ap = [
    0.9844, 1.0000, 0.9844, 1.0000, 1.0000, 0.9868, 1.0000, 0.9868,
    1.0000, 1.0000, 0.9772, 0.9896, 0.9742, 0.9886, 0.9891, 0.9598,
    0.9750, 0.9316, 0.9683, 0.9781, 0.9227, 0.9456, 0.8827, 0.9108,
    0.9105
]

bm_ap = [
    0.8281, 0.8194, 0.7969, 0.7812, 0.7679, 0.7895, 0.7750, 0.7632,
    0.7763, 0.7647, 0.7614, 0.8229, 0.7614, 0.7625, 0.8000, 0.7609,
    0.7600, 0.8021, 0.7727, 0.7727, 0.9344, 0.9483, 0.9256, 0.9288,
    0.9551
]

def normalize_all_lists_together(*args):
    # Combine all lists into a single array for normalization
    combined = np.concatenate(args)
    # Normalize the combined array
    normalized_combined = (combined - combined.min()) / (combined.max() - combined.min())
    # Split the normalized array back into individual lists of original size
    normalized_lists = []
    start = 0
    for original_list in args:
        end = start + len(original_list)
        normalized_lists.append(list(normalized_combined[start:end]))
        start = end
    return normalized_lists

# Example of how to use the function:
# Assuming drnl_ap, erb_ap, ... are defined as lists
drnl_ap,  erb_ap,  lyon_ap,  senef_ap,ar_ap,  match_ap,  wave_ap,  bm_ap = normalize_all_lists_together(drnl_ap, erb_ap, lyon_ap, senef_ap, ar_ap, match_ap, wave_ap, bm_ap)

'''
data_matrix = np.array([
    [np.nan]*25,ar1, ar2, ar3,
    [np.nan]*25,match1, match2, match3,
    [np.nan]*25,bm1, bm2, bm3,
    [np.nan]*25,lyon1, lyon2,
    [np.nan]*25,wave1, wave2,
    [np.nan]*25,drnl1, drnl2,
    [np.nan]*25,senef1, senef2, senef3,
    [np.nan]*25,erb1, erb2, erb3
])
'''
data_matrix = np.array([
    ar_ap, ar1, ar2, ar3, [np.nan]*25,
    match_ap,match1, match2, match3, [np.nan]*25,
    bm_ap,bm1, bm2, bm3, [np.nan]*25,
    lyon_ap,lyon1, lyon2, [np.nan]*25,
    wave_ap,wave1, wave2, [np.nan]*25,
    drnl_ap,drnl1, drnl2, [np.nan]*25,
    senef_ap,senef1, senef2, senef3, [np.nan]*25,
    erb_ap,erb1, erb2, erb3
])

# Create a list of parameters, grouped by algorithm
parameter_names = [f"{algo}: {param}" for algo, params in algorithms.items() for param in params]


# Improved formatting for the heatmap
# Bold algorithm names and remove ticks next to them

# Function to format the parameter names with indentation and bold for algorithms
def format_and_bold_parameter_names(algorithms):
    formatted_names = []
    bold_indices = []
    for algo, params in algorithms.items():
        if type(algo)== int:
            bold_indices.append(len(formatted_names))  # Mark the algorithm name for bold
            formatted_names.append('')  # Add the algorithm name without indentation
            continue
        else:
            bold_indices.append(len(formatted_names))  # Mark the algorithm name for bold
            formatted_names.append(f"{algo}")  # Add the algorithm name without indentation
        for param in params:
            if param == '':
                continue
            else:
                formatted_names.append(f"    {param}")  # Add the parameter names with indentation
    return formatted_names, bold_indices

# Generate formatted parameter names and indices for bold font
formatted_parameter_names, bold_indices = format_and_bold_parameter_names(algorithms)

data_with_separators = np.random.rand(len(formatted_parameter_names), 25)

for i, name in enumerate(formatted_parameter_names):
    if type(name) == int:
        data_with_separators[i] = np.nan
        formatted_parameter_names[i]= ''
        continue
    if name in algorithms.keys():  # Set the row to NaN for algorithm names
        data_with_separators[i] = data_matrix[i]
    else:
        data_with_separators[i] = data_matrix[i]+1


# Create a figure and axis for customizations
fig, ax = plt.subplots(figsize=(15, 10))


#### ROW NORMALIZATION FOR BETTER VISUALIZATION
df = pd.DataFrame(data_with_separators)
df_norm_row = df.apply(lambda x: (x-x.mean())/x.std(), axis = 1)

# with normalization
# sns.heatmap(df_norm_row, ax=ax, annot=False, cmap=cmap, cbar=False, yticklabels=formatted_parameter_names)

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap


def create_dual_focused_colormap(center1, center2, width1, width2, base_colormap, resolution=256):
    """
    Create a colormap that has more resolution around two specific center values.

    Args:
    center1 (float): The first center point in the data range (0 to 1) to focus on.
    center2 (float): The second center point in the data range (0 to 1) to focus on.
    width1 (float): The width around the first center to spread the focus.
    width2 (float): The width around the second center to spread the focus.
    base_colormap (str): The name of the base colormap to use.
    resolution (int): The resolution of the colormap.

    Returns:
    LinearSegmentedColormap: The new colormap with dual focused resolution.
    """
    indices = np.linspace(0, 1, resolution)

    # Two transformation functions for each focus area
    transform1 = 0.5 + (np.tanh((indices - center1) / width1) / np.tanh(1 / width1) / 2)
    transform2 = 0.5 + (np.tanh((indices - center2) / width2) / np.tanh(1 / width2) / 2)

    # Combine transformations: average or another combination can be applied
    transformed = (transform1 + transform2) / 2

    # Get the colors from the original colormap
    base_cmap = plt.get_cmap(base_colormap)
    colors = base_cmap(transformed)

    # Create a new colormap from these transformed colors
    new_cmap = LinearSegmentedColormap.from_list('dual_focused_cmap', colors, N=resolution)
    return new_cmap


# Example usage with dual focus centers
cmap2 = create_dual_focused_colormap(center1=0.75, center2=0.995, width1=0.2, width2=0.05, base_colormap='viridis')

# Create a custom colormap
#cmap = sns.color_palette("YlOrRd", 256)

# adapt the colormaps such that the "under" or "over" color is "none"
cmap1 = plt.get_cmap('YlOrRd').copy()
cmap1.set_under('none')
#cmap2 = plt.get_cmap('rainbow').copy()
cmap2.set_over('none')


# without normalization
sns.heatmap(df, ax=ax, vmin = 1, annot=False, cmap = cmap1, cbar=False, yticklabels=formatted_parameter_names)
sns.heatmap(df, ax=ax, vmax = 1,annot=False, cmap=cmap2, cbar=True, yticklabels=formatted_parameter_names)

# Set x-axis labels
ax.set_xticks(np.arange(25) + 0.5)
ax.set_xticklabels(np.arange(1, 26))
ax.set_xlabel('Experiments', fontsize=16, weight='bold')  # Set the x-axis label
ax.set_title("Parameters resulting in best A' scores heatmap", fontsize=20, weight='bold')  # Add a title

# Apply bold font to algorithm names and remove ticks next to them
for i, label in enumerate(ax.get_yticklabels()):
    if i in bold_indices and type(label)!=int:
        label.set_weight('bold')
        label.set_size(15)
    elif i in bold_indices and type(label)==int:
        label.set_size(0)
    else:
        label.set_size(15)
    label.set_rotation(0)  # Set rotation to 0 for all

# Remove the tick marks for algorithm names (set to zero length)
ticks = ax.yaxis.get_major_ticks()
for i in bold_indices:
    ticks[i].tick1line.set_markersize(0)  # Set the size of ticks to 0 (invisible)

# Show the heatmap
plt.tight_layout()
plt.savefig('best_param_heatmap.eps', format='eps')
plt.savefig('best_param_heatmap.png', format='png')

plt.show()

