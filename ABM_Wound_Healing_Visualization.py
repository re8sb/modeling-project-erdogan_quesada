# -*- coding: utf-8 -*-
"""
Created on Wed Apr 14 19:29:54 2021

@author: luque
"""

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats

sns.set_style("white")

df_50 = pd.read_csv("data_50.csv")
df_60 = pd.read_csv("data_60.csv")
df_70 = pd.read_csv("data_70.csv")
df_80 = pd.read_csv("data_80.csv")
df_90 = pd.read_csv("data_90.csv")
df_100 = pd.read_csv("data_100.csv")
df_max_bacteria = pd.read_csv("max_bacteria.csv")

# Mean count in time

# Bacteria 

bacteria_50 = df_50.iloc[:, [0, 3, 6, 9, 12, 15, 18, 21, 24, 27]]
bacteria_60 = df_60.iloc[:, [0, 3, 6, 9, 12, 15, 18, 21, 24, 27]]
bacteria_70 = df_70.iloc[:, [0, 3, 6, 9, 12, 15, 18, 21, 24, 27]]
bacteria_80 = df_80.iloc[:, [0, 3, 6, 9, 12, 15, 18, 21, 24, 27]]
bacteria_90 = df_90.iloc[:, [0, 3, 6, 9, 12, 15, 18, 21, 24, 27]]
bacteria_100 = df_100.iloc[:, [0, 3, 6, 9, 12, 15, 18, 21, 24, 27]]

bacteria_50['mean'] = bacteria_50.mean(axis=1)
bacteria_60['mean'] = bacteria_60.mean(axis=1)
bacteria_70['mean'] = bacteria_70.mean(axis=1)
bacteria_80['mean'] = bacteria_80.mean(axis=1)
bacteria_90['mean'] = bacteria_90.mean(axis=1)
bacteria_100['mean'] = bacteria_100.mean(axis=1)

fig,ax = plt.subplots()
plt.plot(bacteria_50['mean'], linewidth=3, color = (0, 0.8, 0.8))
plt.plot(bacteria_60['mean'], linewidth=3, color = (0, 0.7, 0.7))
plt.plot(bacteria_70['mean'], linewidth=3, color = (0, 0.6, 0.6))
plt.plot(bacteria_80['mean'], linewidth=3, color = (0, 0.4, 0.4))
plt.plot(bacteria_90['mean'], linewidth=3, color = (0, 0.2, 0.2))
plt.plot(bacteria_100['mean'], linewidth=3, color = (0, 0.1, 0.1))
plt.xlim([0, 59])
plt.ylim([0, 650])
plt.xlabel('Time (hours)', fontsize=20)
plt.ylabel('Bacteria Count', fontsize=20)
plt.legend(['50%', '60%', '70%', '80%', '90%', '100%'], fontsize=12)
plt.setp(ax.get_xticklabels(), fontsize=14)
plt.setp(ax.get_yticklabels(), fontsize=14)
plt.savefig('Bacteria.png', dpi = 300, bbox_inches = "tight")
plt.show()

# Neutrophils 

neutrophils_50 = df_50.iloc[:, [1, 4, 7, 10, 13, 16, 19, 22, 25, 28]]
neutrophils_60 = df_60.iloc[:, [1, 4, 7, 10, 13, 16, 19, 22, 25, 28]]
neutrophils_70 = df_70.iloc[:, [1, 4, 7, 10, 13, 16, 19, 22, 25, 28]]
neutrophils_80 = df_80.iloc[:, [1, 4, 7, 10, 13, 16, 19, 22, 25, 28]]
neutrophils_90 = df_90.iloc[:, [1, 4, 7, 10, 13, 16, 19, 22, 25, 28]]
neutrophils_100 = df_100.iloc[:, [1, 4, 7, 10, 13, 16, 19, 22, 25, 28]]

neutrophils_50['mean'] = neutrophils_50.mean(axis=1)
neutrophils_60['mean'] = neutrophils_60.mean(axis=1)
neutrophils_70['mean'] = neutrophils_70.mean(axis=1)
neutrophils_80['mean'] = neutrophils_80.mean(axis=1)
neutrophils_90['mean'] = neutrophils_90.mean(axis=1)
neutrophils_100['mean'] = neutrophils_100.mean(axis=1)

fig,ax = plt.subplots()
plt.plot(neutrophils_50['mean'], linewidth=3, color = (0, 0.8, 0.8))
plt.plot(neutrophils_60['mean'], linewidth=3, color = (0, 0.7, 0.7))
plt.plot(neutrophils_70['mean'], linewidth=3, color = (0, 0.6, 0.6))
plt.plot(neutrophils_80['mean'], linewidth=3, color = (0, 0.4, 0.4))
plt.plot(neutrophils_90['mean'], linewidth=3, color = (0, 0.2, 0.2))
plt.plot(neutrophils_100['mean'], linewidth=3, color = (0, 0.1, 0.1))
plt.xlim([0, 110])
plt.ylim([0, 650])
plt.xlabel('Time (hours)', fontsize=20)
plt.ylabel('Neutrophil Count', fontsize=20)
plt.legend(['50%', '60%', '70%', '80%', '90%', '100%'], fontsize=12)
plt.setp(ax.get_xticklabels(), fontsize=14)
plt.setp(ax.get_yticklabels(), fontsize=14)
plt.savefig('Neutrophils.png', dpi = 300, bbox_inches = "tight")
plt.show()

# Macrophages
macrophages_50 = df_50.iloc[:, [2, 5, 8, 11, 14, 17, 20, 23, 26, 29]]
macrophages_60 = df_60.iloc[:, [2, 5, 8, 11, 14, 17, 20, 23, 26, 29]]
macrophages_70 = df_70.iloc[:, [2, 5, 8, 11, 14, 17, 20, 23, 26, 29]]
macrophages_80 = df_80.iloc[:, [2, 5, 8, 11, 14, 17, 20, 23, 26, 29]]
macrophages_90 = df_90.iloc[:, [2, 5, 8, 11, 14, 17, 20, 23, 26, 29]]
macrophages_100 = df_100.iloc[:, [2, 5, 8, 11, 14, 17, 20, 23, 26, 29]]

macrophages_50['mean'] = macrophages_50.mean(axis=1)
macrophages_60['mean'] = macrophages_60.mean(axis=1)
macrophages_70['mean'] = macrophages_70.mean(axis=1)
macrophages_80['mean'] = macrophages_80.mean(axis=1)
macrophages_90['mean'] = macrophages_90.mean(axis=1)
macrophages_100['mean'] = macrophages_100.mean(axis=1)

fig,ax = plt.subplots()
plt.plot(macrophages_50['mean'], linewidth=3, color = (0, 0.8, 0.8))
plt.plot(macrophages_60['mean'], linewidth=3,color = (0, 0.7, 0.7))
plt.plot(macrophages_70['mean'],  linewidth=3, color = (0, 0.6, 0.6))
plt.plot(macrophages_80['mean'], linewidth=3, color = (0, 0.4, 0.4))
plt.plot(macrophages_90['mean'], linewidth=3, color = (0, 0.2, 0.2))
plt.plot(macrophages_100['mean'], linewidth=3, color = (0, 0.1, 0.1))
plt.xlim([0, 190])
plt.ylim([0, 400])
plt.xlabel('Time (hours)', fontsize=20)
plt.ylabel('Macrophage Count', fontsize=20)
plt.legend(['50%', '60%', '70%', '80%', '90%', '100%'], fontsize=12, loc=1)
plt.setp(ax.get_xticklabels(), fontsize=14)
plt.setp(ax.get_yticklabels(), fontsize=14)
plt.savefig('Macrophages.png', dpi = 300, bbox_inches = "tight")
plt.show()

# Comparison of Maximum Bacteria Count (ANOVA-Kurskal Wallis)

plt.figure(figsize=(10, 6))
ax = sns.boxplot(x="suceptibility", y="maxbacteria", data=df_max_bacteria, palette="Blues")
ax.set_xlabel("Probability of Bacteria Death (%)",fontsize=20)
ax.set_ylabel("Maximum Bacteria Count",fontsize=20)
ax.tick_params(labelsize=14)
plt.text(0, 230, 'Kruskal Wallis p-value = 0.0194', color='k', size=16)
plt.savefig('MaxBacteriaCount.png', dpi = 300)
plt.show()

# Linear regression analysis

# initialize list of lists
data = [[50, 48], [60, 44], [70, 44], [80, 41], [90, 38], [100, 33]]
  
# Create the pandas DataFrame
df_reg = pd.DataFrame(data, columns = ['suceptibility', 'time'])

lin_reg = stats.linregress(df_reg.suceptibility, df_reg.time)

plt.figure()
plt.rcParams['font.size'] = '14'
ax1 = df_reg.plot(kind='scatter', x='suceptibility', y='time', color='k', alpha=0.5, figsize=(10, 7))
df_reg.plot(kind='scatter', x='suceptibility', y='time', color='k', alpha=0.5, figsize=(10, 7), ax=ax1)

# Regression Lines
plt.plot(df_reg.suceptibility, lin_reg.intercept + lin_reg.slope*df_reg.suceptibility, 'r', color='g', linewidth=2)

# Regression equations
plt.text(50, 43, 'y = {:.2f}+{:.2f}*x'.format(lin_reg[1], lin_reg[0]), color='k', size=16)
plt.text(50, 44, 'R^2 = -0.972', color='k', size=16)
#plt.legend(fontsize = 16)

# legend, title and labels.
plt.xlabel('Probability of Bacteria Death (%)')
plt.ylabel('Maximum time to clear infection (Hours)')
plt.savefig('LinearRegression.png', dpi = 300)
plt.show()



