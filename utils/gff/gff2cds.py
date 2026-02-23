#! /usr/bin/env python
import argparse
import re

def read_fasta(fasta_file):
    """读取FASTA文件并返回一个字典，键为序列ID，值为序列字符串。"""
    sequences = {}
    with open(fasta_file, 'r') as f:
        sequence_id = None
        sequence = []
        for line in f:
            line = line.strip()
            if line.startswith(">"):
                if sequence_id:
                    sequences[sequence_id] = ''.join(sequence)
                sequence_id = line[1:].split()[0]  # 取第一个空格前的部分作为ID
                sequence = []
            else:
                sequence.append(line)
        sequences[sequence_id] = ''.join(sequence)  # 添加最后一个序列
    return sequences

def translate_dna_to_protein(dna_seq):
    """将DNA序列翻译成蛋白质序列。这里使用简化的密码子表。"""
    codon_table = {
        'ATA':'I', 'ATC':'I', 'ATT':'I', 'ATG':'M',
        'ACA':'T', 'ACC':'T', 'ACG':'T', 'ACT':'T',
        'AAC':'N', 'AAT':'N', 'AAA':'K', 'AAG':'K',
        'AGC':'S', 'AGT':'S', 'AGA':'R', 'AGG':'R',
        'CTA':'L', 'CTC':'L', 'CTG':'L', 'CTT':'L',
        'CCA':'P', 'CCC':'P', 'CCG':'P', 'CCT':'P',
        'CAC':'H', 'CAT':'H', 'CAA':'Q', 'CAG':'Q',
        'CGA':'R', 'CGC':'R', 'CGG':'R', 'CGT':'R',
        'GTA':'V', 'GTC':'V', 'GTG':'V', 'GTT':'V',
        'GCA':'A', 'GCC':'A', 'GCG':'A', 'GCT':'A',
        'GAC':'D', 'GAT':'D', 'GAA':'E', 'GAG':'E',
        'GGA':'G', 'GGC':'G', 'GGG':'G', 'GGT':'G',
        'TCA':'S', 'TCC':'S', 'TCG':'S', 'TCT':'S',
        'TTC':'F', 'TTT':'F', 'TTA':'L', 'TTG':'L',
        'TAC':'Y', 'TAT':'Y', 'TAA':'*', 'TAG':'*',
        'TGC':'C', 'TGT':'C', 'TGA':'*', 'TGG':'W',
    }
    protein_seq = ''
    # dna_seq = dna_seq.upper()
    for i in range(0, len(dna_seq), 3):
        codon = dna_seq[i:i+3]
        protein_seq += codon_table.get(codon, 'X')  # 使用'X'标记未知的密码子
    return protein_seq

def extract_cds_from_gff(gff_file, genome_sequences):
    """从GFF文件和基因组序列中提取CDS，并按顺序连接每个基因的CDS片段，然后翻译成肽序列。"""
    gene_cds_info = {}
    cds_sequences = {}
    cds_pep_sequences = {}
    gff_lines = {}  # 存储每个CDS ID对应的所有相关GFF行（包括mRNA和CDS）
    mrna_to_cds = {}  # 存储mRNA ID到CDS ID的映射

    with open(gff_file, 'r') as gff:
        for line in gff:
            if line.startswith('#') or not line.strip(): 
                continue
            
            parts = re.split(r'\s+', line.strip())
            if len(parts) < 9: 
                continue

            attributes = parts[8]
            if parts[2] == 'mRNA':
                # 提取mRNA的ID
                mrna_id = None
                for attribute in attributes.split(';'):
                    if attribute.startswith('ID='):
                        mrna_id = attribute.split('=')[1]
                        break
                if mrna_id:
                    if mrna_id not in gff_lines:
                        gff_lines[mrna_id] = []
                    gff_lines[mrna_id].append(line.strip())

            elif parts[2] == 'CDS':
                seq_id = parts[0]
                start = int(parts[3])
                end = int(parts[4])
                strand = parts[6]

                # 提取CDS所属的mRNA ID
                parent_id = None
                for attribute in attributes.split(';'):
                    if attribute.startswith('Parent='):
                        parent_id = attribute.split('=')[1]
                        break

                if not parent_id:
                    print('Error: Parent ID not found for CDS')
                    continue

                # 将CDS行添加到对应mRNA的GFF行列表中
                if parent_id not in gff_lines:
                    gff_lines[parent_id] = []
                gff_lines[parent_id].append(line.strip())

                # 存储CDS信息
                if parent_id not in gene_cds_info:
                    gene_cds_info[parent_id] = []
                gene_cds_info[parent_id].append((seq_id, start, end, strand))

    # 处理每个mRNA的CDS序列
    for mrna_id, cds_parts in gene_cds_info.items():
        cds_parts.sort(key=lambda x: x[1])
        cds_seq_combined = ''
        strand = cds_parts[0][3]  # 获取链的方向

        for seq_id, start, end, _ in cds_parts:
            cds_seq = genome_sequences[seq_id][start-1:end]
            cds_seq_combined += cds_seq

        cds_seq_combined = cds_seq_combined.upper()
        if strand == '-':
            cds_seq_combined = reverse_complement(cds_seq_combined)

        cds_sequences[mrna_id] = cds_seq_combined
        protein_seq = translate_dna_to_protein(cds_seq_combined)
        cds_pep_sequences[mrna_id] = protein_seq

    return cds_sequences, cds_pep_sequences, gff_lines

def reverse_complement(seq):
    """获取DNA序列的反向互补序列。"""
    complement = {'A': 'T', 'C': 'G', 'G': 'C', 'T': 'A'}
    return ''.join(complement[base] for base in reversed(seq))

def main(fasta_file, gff_file, output_prefix):
    # 读取基因组序列
    genome_sequences = read_fasta(fasta_file)

    # 提取CDS并翻译成蛋白质序列，同时保留CDS序列和GFF信息
    cds_sequences, cds_pep_sequences, gff_lines = extract_cds_from_gff(gff_file, genome_sequences)

    # 保存CDS序列到文件
    with open(f"{output_prefix}_cds.fasta", 'w') as cds_file:
        for cds_id, cds_seq in cds_sequences.items():
            cds_file.write(f">{cds_id}\n{cds_seq}\n")

    # 保存肽序列到文件，并将GFF信息分别输出到两个文件
    with open(f"{output_prefix}_pep.fasta", 'w') as pep_file, \
         open(f"{output_prefix}_premature_stop_codons.gff", 'w') as stop_file, \
         open(f"{output_prefix}_complete_proteins.gff", 'w') as complete_file:
        
        # 写入GFF文件头部注释
        stop_file.write("##gff-version 3\n")
        complete_file.write("##gff-version 3\n")
        
        for mrna_id, pep_seq in cds_pep_sequences.items():
            if '*' in pep_seq[0:-1]:
                # 将含有提前终止密码子的基因的完整GFF信息（包括mRNA和CDS）写入到停止密码子文件
                for gff_line in gff_lines[mrna_id]:
                    stop_file.write(f"{gff_line}\n")
                continue
            
            # 将成功翻译的基因序列写入到FASTA文件
            pep_file.write(f">{mrna_id}\n{pep_seq}\n")
            
            # 将成功翻译的基因的完整GFF信息（包括mRNA和CDS）写入到完整蛋白质文件
            for gff_line in gff_lines[mrna_id]:
                complete_file.write(f"{gff_line}\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extract CDS and translate to protein sequences from a GFF file and a genome sequence file.")
    parser.add_argument("-g", "--genome_file", required=True, help="Path to the genome sequence file in FASTA format.")
    parser.add_argument("-a", "--annotation_gff_file", required=True, help="Path to the GFF file containing gene annotations.")
    parser.add_argument("-o", "--output_prefix", required=True, help="Prefix for the output files.")

    args = parser.parse_args()

    main(args.genome_file, args.annotation_gff_file, args.output_prefix)