#! /usr/bin/env python
from ete3 import Tree

def normalize_tree_clocklike(node, max_depth=None):
    if max_depth is None:
        max_depth = get_average_leaf_distance(node)
    if node.is_root():
        children = node.children
        for child in children:
            if child.is_leaf():
                child.dist = max_depth
            else:
                normalize_tree_clocklike(child, max_depth)
    elif not node.is_leaf():
        children = node.children
        parent_distance = node.dist
        child_distance = get_average_leaf_distance(node)
        new_parent_distance = (parent_distance / (parent_distance + child_distance)) * max_depth
        new_child_distance = max_depth - new_parent_distance
        node.dist = new_parent_distance
        for child in children:
            if child.is_leaf():
                child.dist = new_child_distance
            else:
                normalize_tree_clocklike(child, new_child_distance)

def get_average_leaf_distance(node):
    leaves = node.get_leaves()
    total_distance = sum(node.get_distance(leaf) for leaf in leaves)
    average_distance = total_distance / len(leaves)
    return average_distance

def get_scaled_clock_tree_newick(input_tree_newick, total_length=1.0):
    tree = Tree(input_tree_newick)
    normalize_tree_clocklike(tree)
    max_path_length = max([node.get_distance(tree) for node in tree.iter_leaves()])
    scale_factor = total_length / max_path_length
    for node in tree.traverse():
        node.dist *= scale_factor
    return tree.write(format=1)

def process_trees(input_file_path, output_file_path, total_length=1.0):
    with open(input_file_path, 'r') as input_file, open(output_file_path, 'w') as output_file:
        for line in input_file:
            tree_newick = line.strip()
            if tree_newick:
                scaled_clock_tree_newick = get_scaled_clock_tree_newick(tree_newick, total_length)
                output_file.write(scaled_clock_tree_newick + '\n')

input_file_path = 'all.treefile' 
output_file_path = 'output_scaled_trees.txt' 
desired_total_length = 1.0  

process_trees(input_file_path, output_file_path, desired_total_length)
