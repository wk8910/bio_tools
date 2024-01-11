import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

# 加载数据
file_path = 'QianJinTeng.count.txt.tpm'
data = pd.read_csv(file_path, delimiter='\t', index_col=0)
data = data.loc[(data != 0).any(axis=1)]

# 计算每个组织类型两个重复样本的平均表达量
data_mean = pd.DataFrame()
data_mean['fruit'] = data[['fruit1', 'fruit2']].mean(axis=1)
data_mean['leaf'] = data[['leaf1', 'leaf2']].mean(axis=1)
data_mean['root'] = data[['root1', 'root2']].mean(axis=1)
data_mean['stem'] = data[['stem1', 'stem2']].mean(axis=1)
log_data_mean = np.log2(data_mean + 1)

data_transposed = data_mean.T
# 对平均后的数据进行标准化处理
scaler = StandardScaler()
scaled_data_mean = scaler.fit_transform(data_transposed)

scaled_data_mean=scaled_data_mean.T

# 再次使用K-means聚类，仍然假定聚类数为4
n_clusters = 4
kmeans_mean = KMeans(n_clusters=n_clusters, random_state=0)
clusters_mean = kmeans_mean.fit_predict(scaled_data_mean)

# 将聚类结果添加到平均后的数据框中
clustered_data_mean = data_mean.copy()
clustered_data_mean['Cluster'] = clusters_mean

# 输出聚类结果
output_file_path = 'clustered_data.csv'
clustered_data_mean.to_csv(output_file_path, sep='\t', index=True)

scaled_data_mean_df = pd.DataFrame(scaled_data_mean, index=data_mean.index, columns=data_mean.columns)
scaled_data_mean_df['Cluster'] = clusters_mean
# scaled_data_mean_df.to_csv("scaled_data_mean.txt", sep='\t', index=True)

# 确定子图的布局，例如如果有4个聚类，可以使用2行2列的布局
rows = 2  # 这个值可以根据聚类的数量和您希望的布局进行调整
cols = 2  # 同上

# 设置折线的颜色和透明度
line_color = 'orange'  # 您可以选择任何您喜欢的颜色
line_alpha = 0.01  # 设置透明度，范围从0（完全透明）到1（完全不透明）
x_labels = ["fruit", "root", "leaf", "stem"]

plt.rcParams['pdf.fonttype'] = 42
plt.rcParams['ps.fonttype'] = 42

# 创建一个PDF文件
with PdfPages('kmeans.pdf') as pdf:  # 替换为您想要保存的文件路径
    fig, axes = plt.subplots(rows, cols, figsize=(12, 8))  # 调整图表尺寸

    # 遍历每个聚类来创建子图
    for cluster in range(n_clusters):
        ax = axes[cluster // cols, cluster % cols]  # 定位当前子图的位置
        cluster_data = scaled_data_mean_df[scaled_data_mean_df['Cluster'] == cluster].drop('Cluster', axis=1)
        cluster_data = cluster_data.reindex(columns=x_labels)
        # 在当前子图上绘制每个基因的折线
        for index, row in cluster_data.iterrows():
            ax.plot(row, color=line_color, alpha=line_alpha)
        ax.plot(cluster_data.mean(), color='black')
        ax.set_title(f'Cluster {cluster}')
        # ax.set_xlabel('Organ')
        ax.set_ylabel('Scaled gene expression quantity')
        ax.tick_params(axis='x', rotation=45)
        # 可以选择不在每个子图中显示图例

    # 调整子图间距
    plt.tight_layout()

    # 将整个布局保存到PDF
    pdf.savefig(fig)
    plt.close(fig)
