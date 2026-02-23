#! /usr/bin/env python
import argparse
import pandas as pd
from scipy.stats import fisher_exact
from statsmodels.stats.multitest import multipletests
import numpy as np
import re

# Function to calculate enrichment and perform Fisher's exact test
def calculate_enrichment(category_count, class_count, both_count, total_count):
    # Check for negative values before constructing the contingency table
    if class_count - both_count < 0:
        print(f"Error: Negative value in 'class_count - both_count' with class_count={class_count}, both_count={both_count}")
    if category_count - both_count < 0:
        print(f"Error: Negative value in 'category_count - both_count' with category_count={category_count}, both_count={both_count}")
    if total_count - category_count - class_count + both_count < 0:
        print(f"Error: Negative value in 'total_count - category_count - class_count + both_count' with total_count={total_count}, category_count={category_count}, class_count={class_count}, both_count={both_count}")

    # Construct the contingency table with max to avoid negative values
    contingency_table = np.array([
        [both_count, max(class_count - both_count, 0)],
        [max(category_count - both_count, 0), max(total_count - category_count - class_count + both_count, 0)]
    ])

    # Perform Fisher's exact test
    p_value = fisher_exact(contingency_table, alternative='greater')[1]

    # Calculate enrichment factor
    if category_count > 0 and class_count > 0:
        enrichment_factor = (both_count / category_count) / (class_count / total_count)
    else:
        enrichment_factor = 0

    return p_value, enrichment_factor

def read_annotation_and_parse(file_path):
    annotation_data = pd.read_csv(file_path, sep='\t')
    GO_data_gene = set()
    annotations_index = {}

    for index, row in annotation_data.iterrows():
        gene_id = row['gene_id']
        anno_info = row['KEGG_pathway']
        if pd.notnull(anno_info):
            GO_data_gene.add(gene_id)
            # for annotation in re.findall(r'GO:\d+\sGO:\w+(?:(?!GO:).)*', anno_info):
            for annotation in anno_info.split(';'):
                annotation = annotation.rstrip()
                if annotation not in annotations_index:
                    annotations_index[annotation] = []
                annotations_index[annotation].append(gene_id)

    return GO_data_gene, annotations_index

def read_gene_list(file_path):
    gene_list = []
    with open(file_path, 'r') as file:
        for line in file:
            gene_list.append(line.strip())
    return gene_list

def calculate_enrichment_results(fore_genes, annotations_index, GO_data_gene, background_genes=None):
    data_result = []

    for annotation, index_list in annotations_index.items():
        # Use background genes if provided, else use all genes in annotations
        relevant_genes = background_genes if background_genes else GO_data_gene

        # Calculate category_count as the intersection of the annotation's index list and the relevant genes
        category_count = len(set(index_list) & set(relevant_genes))

        fore_gene_count = len(fore_genes)
        overlap_count = len(set(fore_genes) & set(index_list))

        # Calculate background gene count
        background_gene_count = len(relevant_genes)

        p_value, enrichment_factor = calculate_enrichment(category_count, fore_gene_count, overlap_count, background_gene_count)
        data_result.append({
            'Annotation': annotation,
            'Category_Count': category_count,
            'Fore_Gene_Count': fore_gene_count,
            'Overlap_Count': overlap_count,
            'Background_Gene_Count': background_gene_count,
            'Enrichment_Factor': enrichment_factor,
            'P_Value': p_value
        })

    return data_result

def fdr_correction(data):
    p_values = data['P_Value'].values
    _, p_values_fdr, _, _ = multipletests(p_values, method='fdr_bh')
    data['P_Value_fdr'] = p_values_fdr
    return data

def main():
    parser = argparse.ArgumentParser(description='Calculate enrichment and perform Fisher\'s exact test for GO annotations.')
    parser.add_argument('-f', '--foreground', required=True, help='File containing foreground genes')
    parser.add_argument('-b', '--background', help='File containing background genes (optional)')
    parser.add_argument('-a', '--annotations', required=True, help='File containing GO annotations')
    parser.add_argument('-o', '--output', default='kegg_enrichment_results.csv', help='Output file name (default: kegg_enrichment_results.csv)')
    args = parser.parse_args()

    GO_data_gene, annotations_index = read_annotation_and_parse(args.annotations)

    fore_genes = read_gene_list(args.foreground)

    if args.background:
        background_genes = read_gene_list(args.background)
    else:
        background_genes = None

    data_result = calculate_enrichment_results(fore_genes, annotations_index, GO_data_gene, background_genes)

    results = pd.DataFrame(data_result)
    results.set_index('Annotation', inplace=True)
    results = results.sort_values(by='P_Value')
    results = fdr_correction(results)
    results.to_csv(args.output, index=True, sep="\t")

if __name__ == "__main__":
    main()
