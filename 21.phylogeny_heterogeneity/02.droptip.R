library("ape")
a=read.tree(file="01.filter.pl.tre")
b=a
for(i in 1:length(a)){
      b[[i]]=drop.tip(a[[i]],c("A","C"))
}
write.tree(b,file="clean.tre")
      