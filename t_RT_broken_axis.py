import matplotlib.pyplot as plt
import numpy as np

# Data
methods = ['AR', 'Matched', "Vencovský's", "Lyon's",
           'Wavelet', 'DRNL', "Seneff's", 'ERBlet']
x = np.arange(len(methods))
y = np.array([1.41, 1.54, 1239.92, 90.22, 2.99, 22.82, 16.30, 27.11])

fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True)
fig.subplots_adjust(hspace=0.05)  # adjust space between Axes

# plot the same data on both Axes
ax1.bar(x, y, color='blue')
ax2.bar(x, y, color='blue')

# zoom-in / limit the view to different portions of the data
ax1.set_ylim(1000, 1300)  # outliers only
ax2.set_ylim(0, 100)  # most of the data

# hide the spines between ax and ax2
ax1.spines.bottom.set_visible(False)
ax2.spines.top.set_visible(False)
ax1.xaxis.tick_top()
ax1.tick_params(labeltop=False)  # don't put tick labels at the top
ax2.xaxis.tick_bottom()

# Now, let's turn towards the cut-out slanted lines.
# We create line objects in axes coordinates, in which (0,0), (0,1),
# (1,0), and (1,1) are the four corners of the Axes.
# The slanted lines themselves are markers at those locations, such that the
# lines keep their angle and position, independent of the Axes size or scale
# Finally, we need to disable clipping.

d = .5  # proportion of vertical to horizontal extent of the slanted line
kwargs = dict(marker=[(-1, -d), (1, d)], markersize=12,
              linestyle="none", color='k', mec='k', mew=1, clip_on=False)
ax1.plot([0, 1], [0, 0], transform=ax1.transAxes, **kwargs)
ax2.plot([0, 1], [1, 1], transform=ax2.transAxes, **kwargs)

# add method names to x-axis
plt.xticks(x, methods, rotation=45, ha='right')

# set y-axis label
ax2.set_ylabel('T_{RT} (%)')

# set plot title
plt.suptitle('T_RT of Algorithms')

plt.show()
