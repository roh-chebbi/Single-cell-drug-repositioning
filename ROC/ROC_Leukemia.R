library(ggplot2)
library(pROC)
library(Seurat)
setwd("./")
#Drug Score ROC
AD<-read.table(file="ApprovedDrugs_TALL.txt",header = F)
VD<-read.table(file="Validated_FDA_Drugs_TALL.txt",header = F)
PD<-unique(c(as.character(AD[,1]),as.character(VD[,1])))
PD.table<-data.frame(drug=PD,group="PD")
Cd<-readRDS("TALL_drugscore_FDA_limma.rds")
Drugs<-unique(as.character(row.names(Cd)))
ND<-setdiff(Drugs,PD)
ND.table<-data.frame(drug=ND,group="ND")
Drug.table<-rbind(PD.table,ND.table)
Cd$drug=row.names(Cd)
Cd<-merge(Cd,Drug.table)
S.roc<-roc(Cd$group, Cd$Drug.therapeutic.score)
name<-paste0("TALL_DrugScore_ROC.pdf")
pdf(file = name,width = 3.5,height = 3.5)
plot.roc(S.roc,print.auc = T,main="Asgard single drug",print.auc.pattern=paste0("Drug Score AUC=",round(S.roc$auc,2)),print.auc.x = .8,print.auc.y = .25, col="#1c61b6")
dev.off()


AD<-read.table(file="ApprovedDrugs_TALL.txt",header = F)
VD<-read.table(file="Validated_FDA_Drugs_TALL.txt",header = F)
PD<-unique(c(as.character(AD[,1]),as.character(VD[,1])))
PD.table<-data.frame(drug=PD,group="PD")
Rocs<-data.frame()
Cd<-readRDS("TALL_drugscore_FDA_limma.rds")
Drugs<-unique(as.character(row.names(Cd)))
ND<-setdiff(Drugs,PD)
ND.table<-data.frame(drug=ND,group="ND")
Drug.table<-rbind(PD.table,ND.table)
Cd$drug=row.names(Cd)
Cd<-merge(Cd,Drug.table)
l.roc<-roc(Cd$group, Cd$Drug.therapeutic.score)
Rocs.temp=data.frame(AUC=l.roc$auc,Method="Limma")
Rocs=rbind(Rocs,Rocs.temp)
Cd<-readRDS("TALL_drugscore_FDA_seurat.rds")
Drugs<-unique(as.character(row.names(Cd)))
ND<-setdiff(Drugs,PD)
ND.table<-data.frame(drug=ND,group="ND")
Drug.table<-rbind(PD.table,ND.table)
Cd$drug=row.names(Cd)
Cd<-merge(Cd,Drug.table)
S.roc<-roc(Cd$group, Cd$Drug.therapeutic.score)
Rocs.temp=data.frame(AUC=S.roc$auc,Method="Seurat")
Rocs=rbind(Rocs,Rocs.temp)
Cd<-readRDS("TALL_drugscore_FDA_DESeq2.rds")
Drugs<-unique(as.character(row.names(Cd)))
ND<-setdiff(Drugs,PD)
ND.table<-data.frame(drug=ND,group="ND")
Drug.table<-rbind(PD.table,ND.table)
Cd$drug=row.names(Cd)
Cd<-merge(Cd,Drug.table)
D.roc<-roc(Cd$group, Cd$Drug.therapeutic.score)
Rocs.temp=data.frame(AUC=D.roc$auc,Method="DESeq2")
Rocs=rbind(Rocs,Rocs.temp)
Cd<-readRDS("TALL_drugscore_FDA_edgeR.rds")
Drugs<-unique(as.character(row.names(Cd)))
ND<-setdiff(Drugs,PD)
ND.table<-data.frame(drug=ND,group="ND")
Drug.table<-rbind(PD.table,ND.table)
Cd$drug=row.names(Cd)
Cd<-merge(Cd,Drug.table)
E.roc<-roc(Cd$group, Cd$Drug.therapeutic.score)
Rocs.temp=data.frame(AUC=E.roc$auc,Method="edgeR")
Rocs=rbind(Rocs,Rocs.temp)
name<-paste0("TALL_DEG.Drug_ROC.pdf")
pdf(file = name,width = 3.5,height = 3.5)
plot.roc(l.roc,print.auc = T,main="DEG methods comparison",print.auc.pattern=paste0("Limma AUC=",round(l.roc$auc,2)),print.auc.x = .8,print.auc.y = .45, col="#EE7785")
plot.roc(S.roc,print.auc = T,print.auc.pattern=paste0("Seurat AUC=",round(S.roc$auc,2)),print.auc.x = .8,print.auc.y = .35,add = TRUE, col="#67D5B5")
plot.roc(D.roc,print.auc = T,print.auc.pattern=paste0("DESeq2 AUC=",round(D.roc$auc,2)),print.auc.x = .8,print.auc.y = .25, add = TRUE,col="#84B1ED")
plot.roc(E.roc,print.auc = T,print.auc.pattern=paste0("edgeR AUC=",round(E.roc$auc,2)),print.auc.x = .8,print.auc.y = .15,add = TRUE, col="#1c61b6")
dev.off()

#Single cluster size
data<-readRDS("TALL_SCdata_Tcell.rds")
cells<-data@meta.data
cells<-subset(cells,type=="Pre-T ALL")
cells<-cells$celltype
cell.count<-table(cells)
cell.count<-cell.count[which(cell.count>3)]
cells.freq<-round(100*cell.count/length(cells),2)

#Single cluster ROC
library(cmapR)
AD<-read.table(file="ApprovedDrugs_TALL.txt",header = F)
VD<-read.table(file="Validated_FDA_Drugs_TALL.txt",header = F)
VC<-read.table(file="ValidatedCompounds_TALL.txt",header = F)
PD<-unique(c(as.character(AD[,1]),as.character(VD[,1]),as.character(VC[,1])))
PD.table<-data.frame(drug=PD,group="PD")
path<-"Single_cluster_TALL/"
file<-"cs_n4x476251.gct"
my_ds <- parse_gctx(paste0(path,file))
Drug.data<-my_ds@mat
Drugs<-subset(my_ds@rdesc,pert_type=="trt_cp")
Drug.data<-Drug.data[rownames(Drugs),]
Drugs<-Drugs$pert_iname
Drug.data<-cbind(Drugs,Drug.data)
colnames(Drug.data)[1]<-"drug"
Drug.data<-as.data.frame(Drug.data)
S.rocs<-vector()
A.rocs<-vector()
G.rocs<-vector()
for(i in 2:ncol(Drug.data)){
  #i=5
  c<-colnames(Drug.data)[i]
  A.drug.data<-tapply(as.numeric(Drug.data[,i]),Drug.data$drug,sum)
  A.drug.data<-data.frame(drug=names(A.drug.data),score=as.numeric(A.drug.data))
  Drugs<-unique(as.character(A.drug.data$drug))
  ND<-setdiff(Drugs,PD)
  ND.table<-data.frame(drug=ND,group="ND")
  Drug.table<-rbind(PD.table,ND.table)
  A.drug.data<-merge(A.drug.data,Drug.table)
  G.drug.data<-tapply(as.numeric(Drug.data[,i]),Drug.data$drug,mean)
  G.drug.data<-data.frame(drug=names(G.drug.data),score=as.numeric(G.drug.data))
  Drugs<-unique(as.character(G.drug.data$drug))
  ND<-setdiff(Drugs,PD)
  ND.table<-data.frame(drug=ND,group="ND")
  Drug.table<-rbind(PD.table,ND.table)
  G.drug.data<-merge(G.drug.data,Drug.table)
  ScDrug.data<-readRDS("TALL_drugs_limma_all.rds")
  ScDrug.data<-ScDrug.data[[c]]
  ScDrug.data$drug=ScDrug.data$Drug.name
  Drugs<-unique(as.character(ScDrug.data$Drug.name))
  ND<-setdiff(Drugs,PD)
  ND.table<-data.frame(drug=ND,group="ND")
  Drug.table<-rbind(PD.table,ND.table)
  ScDrug.data<-merge(ScDrug.data,Drug.table)
  ScDrug.data<-ScDrug.data[!duplicated(ScDrug.data$drug),]
  Shared.drugs<-intersect(intersect(ScDrug.data$drug,A.drug.data$drug),G.drug.data$drug)
  rm.c1<-grep("BRD-",Shared.drugs)
  rm.c2<-grep("[TUL_]",Shared.drugs)
  rm.c3<-grep("STK",Shared.drugs)
  Shared.drugs<-Shared.drugs[-c(rm.c1,rm.c2,rm.c3)]
  ScDrug.data<-subset(ScDrug.data,drug %in% Shared.drugs)
  A.drug.data<-subset(A.drug.data,drug %in% Shared.drugs)
  G.drug.data<-subset(G.drug.data,drug %in% Shared.drugs)
  S.roc<-roc(ScDrug.data$group, ScDrug.data$P.value)
  A.roc<-roc(A.drug.data$group, A.drug.data$score)
  G.roc<-roc(G.drug.data$group, G.drug.data$score)
  pdf(file = paste0("Pipelines_",c,".pdf"),width = 3.5,height = 3.5)
  plot.roc(S.roc,print.auc = T,main=paste0(c," (",cells.freq[c],"%)"),print.auc.x = .65,print.auc.y = .25,print.auc.pattern=paste0("Asgard AUC=",round(S.roc$auc,2)),col="#EE7785")
  plot.roc(A.roc,print.auc = T,print.auc.x = .65,print.auc.y = .15,print.auc.pattern=paste0("Alakwaa AUC=",round(A.roc$auc,2)),add = TRUE, col="#67D5B5")
  plot.roc(G.roc,print.auc = T,print.auc.x = .65,print.auc.y = .05,print.auc.pattern=paste0("Guo AUC=",round(G.roc$auc,2)),add = TRUE, col="#84B1ED")
  dev.off()
  S.rocs<-c(S.rocs,S.roc$auc)
  A.rocs<-c(A.rocs,A.roc$auc)
  G.rocs<-c(G.rocs,G.roc$auc)
}
print(paste0("Asgard: ",mean(S.rocs)))
print(paste0("Alakwaa: ",mean(A.rocs)))
print(paste0("Guo: ",mean(G.rocs)))

#Drug/Compound Score ROC
AD<-read.table(file="ApprovedDrugs_TALL.txt",header = F)
VD<-read.table(file="Validated_FDA_Drugs_TALL.txt",header = F)
VC<-read.table(file="ValidatedCompounds_TALL.txt",header = F)
PD<-unique(c(as.character(AD[,1]),as.character(VD[,1]),as.character(VC[,1])))
PD.table<-data.frame(drug=PD,group="PD")
Cd<-readRDS("TALL_drugscore_all.rds")
Drugs<-unique(as.character(row.names(Cd)))
ND<-setdiff(Drugs,PD)
ND.table<-data.frame(drug=ND,group="ND")
Drug.table<-rbind(PD.table,ND.table)
Cd$drug=row.names(Cd)
Cd<-merge(Cd,Drug.table)
S.roc<-roc(Cd$group, Cd$Drug.therapeutic.score)

#Bulk methods ROC
library(cmapR)
AD<-read.table(file="ApprovedDrugs_TALL.txt",header = F)
VD<-read.table(file="Validated_FDA_Drugs_TALL.txt",header = F)
VC<-read.table(file="ValidatedCompounds_TALL.txt",header = F)
PD<-unique(c(as.character(AD[,1]),as.character(VD[,1]),as.character(VC[,1])))
PD.table<-data.frame(drug=PD,group="PD")
file<-"CLUE/TALL_bulk/cs_n1x476251.gct"
my_ds <- parse_gctx(file)
Drug.data<-my_ds@mat
Drugs<-subset(my_ds@rdesc,pert_type=="trt_cp")
Drug.data<-Drug.data[rownames(Drugs),]
Drug.data<-tapply(as.numeric(Drug.data),Drugs$pert_iname,min)
Drug.data<-Drug.data[which(Drug.data<0)]
ND<-setdiff(Drugs$pert_iname,PD)
ND.table<-data.frame(drug=ND,group="ND")
Drug.table<-rbind(PD.table,ND.table)
Drug.data<-data.frame(drug=names(Drug.data),score=as.numeric(Drug.data))
Drug.data<-merge(Drug.data,Drug.table)
L.roc<-roc(Drug.data$group, Drug.data$score)
Cd<-readRDS("TALL_drugs_bulk_Drinsight.rds")
Cd$drug<-gsub("_.*","",Cd$drug)
Drugs<-unique(as.character(Cd$drug))
ND<-setdiff(Drugs,PD)
ND.table<-data.frame(drug=ND,group="ND")
Drug.table<-rbind(PD.table,ND.table)
Cd<-merge(Cd,Drug.table)
D.roc<-roc(Cd$group, Cd$pval)
name<-paste0("TALL_bulk_ROC_all.pdf")
pdf(file = name,width = 3.5,height = 3.5)
plot.roc(S.roc,print.auc = T,main="Overall",print.auc.pattern=paste0("Asgard AUC=",round(S.roc$auc,2)),print.auc.x = .8,print.auc.y = .35, col="#ad2d3c")
plot.roc(L.roc,print.auc = T,print.auc.pattern=paste0("CLUE AUC=",round(L.roc$auc,2)),print.auc.x = .8,print.auc.y = .25, add = TRUE, col="#1c61b6")
plot.roc(D.roc,print.auc = T,print.auc.pattern=paste0("DrInsight AUC=",round(D.roc$auc,2)),print.auc.x = .8,print.auc.y = .15,add = TRUE, col="#228f6f")
dev.off()

