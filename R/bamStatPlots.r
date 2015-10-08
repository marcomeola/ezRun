###################################################################
# Functional Genomics Center Zurich
# This code is distributed under the terms of the GNU General
# Public License Version 3, June 2007.
# The terms are available here: http://www.gnu.org/licenses/gpl.html
# www.fgcz.ch


plotBamStat = function(resultList, seqLengths, dataset, param, html=NULL){
  conds = ezConditionsFromDataset(dataset, param=param)
  samples = rownames(dataset)
  sampleColors = getSampleColors(conds, samples)
  files = dataset$BAM
  
  if (param$writeIgvSessionLink){
    ezWrite("<h2>Genome Browser</h2>", con=html)
    if (length(files) > 4){
      idx = which(!duplicated(conds))
      idx = idx[1:min(4, length(idx))]
    } else {
      idx = 1:length(files)
    }
    writeIgvSessionLink(getIgvGenome(param), refBuild=param$ezRef["refBuild"], files[idx], html, label="Open Integrative Genomics Viewer")
  }
  
  
  ezWrite("<h2>Read Alignment Statistics</h2>", con=html)  
  ezWrite("<h3>Multi-Matching Reported in Bam File</h3>", con=html)
  ezWrite("<p>The table holds for each sample in column X the number of reads in Millions",
           " that have X matches in the target and are reported in the file.</p>", con=html)
  
  mmValues = integer()
  for (sm in samples){
    mmValues = union(mmValues, as.integer(names(resultList[[sm]]$multiMatchInFileTable)))
  }
  mmCounts = ezMatrix(0, rows=samples, cols=sort(mmValues))
  for (sm in samples){
    mm = resultList[[sm]]$multiMatchInFileTable
    mmCounts[sm, names(mm)] = mm
  }
  
  pngFile = "multiMatchInFile-barplot.png"
  makeAlignmentCountBarPlot(pngFile, mmCounts)
  writeImageColumnToHtml(pngFile, con=html)
  txtFile = "read-alignment-statistics.txt"
  colnames(mmCounts) = paste("#hits: ", colnames(mmCounts))
  colnames(mmCounts)[ncol(mmCounts)] = paste(colnames(mmCounts)[ncol(mmCounts)], "+", sep="")
  ezWrite.table(mmCounts, file=txtFile, head="Sample")
  writeTxtLinksToHtml(txtFile, mime="text/plain", con=html)
  
  for (nm in c("multiMatchTargetTypeCounts", "uniqueMatchTargetTypeCounts")){
    if (!is.null(resultList[[1]][[nm]])){
      readSet = switch(nm,
                       multiMatchTargetTypeCounts="Uniquely and multi-matching reads:",
                       uniqueMatchTargetTypeCounts="Uniquely matching reads:")
      ezWrite("<h3>", readSet, ": Match Count Percentages", "</h3>", con=html)
      tct = getTypeCountTable(resultList, nm)
      ezWrite.table(tct, file=paste(nm, ".txt", sep=""), digits=4)
      tpt = as.matrix(tct)
      for (cn in colnames(tpt)){
        tpt[ ,cn] = tct[ ,cn]/ tct["total", cn] * 100
      }
      minPercentage = 1
      rowsUse = setdiff(rownames(tpt)[apply(tpt, 1, max) > minPercentage], "total")
      tptUse = tpt[rowsUse, , drop=FALSE]
      ezWrite("<table><tr>", con=html)
      if (nrow(tptUse) >= 2 && ncol(tptUse) >= 2){
        tptUseRel = log2(tptUse)
        tptUseRel = tptUseRel - rowMeans(tptUseRel)
        pngFile = paste("typePercentage-", nm, "-heatmap.png", sep="")
        ezHeatmap(tptUseRel,  height=600, width=800, margins=c(10, 12), file=pngFile,
                   lim=c(-2, 2),
                   Rowv=FALSE, Colv=FALSE, main="Relative Prevalence [log2]")
        ezWrite("<td><img src=", pngFile, "></td>", con=html)
      }
      ezWrite("<td>", con=html)
      writeTableToHtml(signif(tptUse, digits=3), head="Match Count<br>Percentages", con=html)
      ezWrite("</td></tr></table>", con=html)
      
      ezWrite("<h3>", readSet, ": Read Starts per Base", "</h3>", con=html)
      ezWrite("<p>Read Starts per Base is equivalent to Coverage divided by Read length</p>", con=html)
      tct = as.matrix(getTypeCoverageTable(resultList, nm))
      ezWrite.table(tct, file=paste(nm, "-coverage.txt", sep=""), digits=4)
      ezWrite("<table><tr>", con=html)
      if (nrow(tct) >= 2 && ncol(tct) >= 2){
        tctRel = log2(sweep(tct, 2, tct["total", ], FUN="/"))
        tctRel = tctRel[rowsUse, , drop=FALSE]
        
        pngFile = paste("typeCoverage-", nm, "-heatmap.png", sep="")
        ezHeatmap(tctRel, file=pngFile, height=600, width=800, margins=c(10, 12),
                   lim=c(-5, 5),
                   Rowv=FALSE, Colv=FALSE, main="Coverage Enrichment")
        ezWrite("<td><img src=", pngFile, "></td>", con=html)
      }
      ezWrite("<td>", con=html)
      writeTableToHtml(signif(tct[rowsUse, ], digits=4), con=html, head="Avg. Read Starts<br>per Base")
      ezWrite("</td></tr></table>", con=html)
      ezWrite("</p>", con=html)
    }
  }
  ## use these two to record the generated png files
  plotBySamples = list()
  plotByStatistics = list()
  
  if (!is.null(resultList[[1]]$fragSizeHist)){
    pngFiles = character()
    for (sm in samples){
      fsh = resultList[[sm]]$fragSizeHist
      pngFiles[sm] = paste(sm, "-fragSizeHist.png", sep="")
      plotBySamples[[sm]] = c(plotBySamples[[sm]], pngFiles[sm])
      plotByStatistics[["Length distribution of fragments for paired reads"]] = c(plotByStatistics[["Length distribution of fragments for paired reads"]], pngFiles[sm])
      ezWrite.table(cbind(Length=fsh$mids, Count=fsh$counts),
                     file=paste(sm, "-fragSizeHist.txt", sep=""), row.names=FALSE)
      png(file=pngFiles[sm], width=600)
      try(
        plot(fsh, xlab="fragment size", main=paste(sm, "-- Length Histogram"), ylim=c(0, max(fsh$counts[-length(fsh$counts)]))) ## don't use the longest fragment size
      )
      dev.off()
    }
  }
  
  pngFiles = character()
  for (sm in samples){
    fsh = resultList[[sm]]$segmentCountHist
    pngFiles[sm] = paste(sm, "-segmentCountHist.png", sep="")
    plotBySamples[[sm]] = c(plotBySamples[[sm]], pngFiles[sm])
    plotByStatistics[["Histogram of aligned segments per read"]] = c(plotByStatistics[["Histogram of aligned segments per read"]], pngFiles[sm])
    ezWrite.table(cbind(Length=fsh$mids, Count=fsh$counts),
                   file=paste(sm, "-segmentCountHist.txt", sep=""), row.names=FALSE)
    png(file=pngFiles[sm], width=600)
    try(
      plot(fsh, xlab="# segments in alignment", main=paste(sm, "-- Histogram of Segments per Alignment"))
    )
    dev.off()
  }
  
  if (!is.null(resultList[[1]][["ErrorRates"]])){
    for(sm in samples){
      pngFiles = character()
      for (nm in names(resultList[[sm]][["ErrorRates"]])){
        errorRate = resultList[[sm]][["ErrorRates"]][[nm]]
        if (!is.null(errorRate)){
          pngFile = ezValidFilename(paste(sm, "_", nm, ".png", sep=""))
          plotPosSpecificErrorRate(errorRate, png=pngFile, main=paste(sm, nm))
          pngFiles[nm] = pngFile
        }
      }
      plotBySamples[[sm]] = c(plotBySamples[[sm]], pngFiles)
      plotByStatistics[["Read position specific error rate"]] = c(plotByStatistics[["Read position specific error rate"]], pngFiles)
    }
  }
  
  if(!is.null(resultList[[1]][["TranscriptsCovered"]])){
    pngFiles = character()
    pngFile = "TranscriptsCovered.png"
    minYlim = 0 #min(sapply(resultList, function(item){min(item[["TranscriptsCovered"]][["counts"]])}))
    minXlim = 0
    maxYlim = max(sapply(resultList, function(item){max(item[["TranscriptsCovered"]][["counts"]])}))
    maxXlim = 130 #max(sapply(resultList, function(item){max(item[["TranscriptsCovered"]][["mids"]])}))
    png(file=pngFile, width=700)
    plot(1, 1, xlim=c(minXlim, maxXlim), ylim=c(minYlim, maxYlim), xlab = "% length covered", ylab="number of isoforms", main="Isoforms Covered Histogram", type="n")
    for(sm in samples){
      transcript_covered = resultList[[sm]][["TranscriptsCovered"]]
      lines(transcript_covered[["mids"]], transcript_covered[["counts"]], col=sampleColors[sm])
    }
    legend("topright", samples, col=sampleColors[samples], cex=1.2, pt.cex=1.5, bty="o", pt.bg="white", lty=1)
    dev.off()
    ezWrite("<h3>Transcripts covered plot</h3>", con=html)
    writeImageColumnToHtml(pngFile, con=html)
    for(sm in samples){
      tlc = resultList[[sm]][["TranscriptsCovered"]]
      pngFiles[sm] = paste(sm, "-transcriptsCovered.png", sep="")
      plotBySamples[[sm]] = c(plotBySamples[[sm]], pngFiles[sm])
      plotByStatistics[["The fraction of isoform length covered"]] = c(plotByStatistics[["The fraction of isoform length covered"]], pngFiles[sm])
      ezWrite.table(cbind(Percents=tlc$mids, Count=tlc$counts),
                     file=paste(sm, "-transcriptsCovered.txt", sep=""), row.names=FALSE)
      png(file=pngFiles[sm], width=700)
      cts = tlc$counts
      names(cts) = tlc$mids
      barplot(cts, xlab="% length covered", main=paste(sm, "-- Isoforms Covered Histogram"), ylab="number of isoforms")
      dev.off()
    }
  }
  
  if(length(resultList[[1]][["genebody_coverage"]]) != 0){ ## TODO this could be done better by searching alls results for a valide genebody_coverage element
    #pngFiles = character()
    minYlim = 0 #min(sapply(resultList, function(item){min(item[["genebody_coverage"]])}))
    maxYlim = 0.08 ## this means we allow at most 10-fold enrichment at a percentile #max(sapply(resultList, function(item){max(item[["genebody_coverage"]])}))
    gbcTemplate = resultList[[1]][["genebody_coverage"]]
    pngMatrix = ezMatrix("", rows=names(gbcTemplate), cols=names(gbcTemplate[[1]]))
    for (rn in rownames(pngMatrix)){
      for (cn in colnames(pngMatrix)){
        pngMatrix[rn, cn] = ezValidFilename(paste("genebody_coverage_", rn, "_", cn, ".png", sep=""))
        png(file=pngMatrix[rn, cn], width=600)
        plot(1, 1, xlim=c(0,100), ylim=c(minYlim, maxYlim), xlab="percentile of geneBody (5'->3')", ylab="relative coverage", 
             main=paste("Genebody coverage", rn, cn), type="n",
             axes=FALSE, frame=TRUE)
        axis(side=2)
        axis(side=1, at=seq(0, 100, by=10))
        covValues = ezMatrix(0, cols=0:100, rows=samples)
        for(sm in samples){
          y = resultList[[sm]][["genebody_coverage"]][[rn]][[cn]]
          if (!is.null(y)){
            covValues[sm, ] = y
            lines(0:100, y, col=sampleColors[sm])
          } else {
            covValues[sm, ] = NA
          }
        }
        #legend("topright", samples, col=sampleColors[samples], cex=1.2, pt.cex=1.5, bty="o", pt.bg="white", lty=1)
        dev.off()
        ezWrite.table(covValues, file=sub(".png$", ".txt", pngMatrix[rn, cn]), head="Name")
      }
    }
    ezWrite("<h3>Genebody coverage plot</h3>", con=html)
    png(file="sampleColors.png", height=length(samples)*15 + 20, width=300)
    par(mar=c(0,0,0,0))
    plot(1,1, axes=FALSE, frame=FALSE, type="n", xlab="", ylab="")
    legend("topleft", samples, fill=sampleColors[samples], border=NA, bty="n", pt.bg="white", title="Sample Colors")
    dev.off()
    writeImageRowToHtml(pngNames="sampleColors.png", con=html)
    writeImageTableToHtml(pngMatrix, con=html)
  }
  
  geneCounts = resultList[[1]][["geneCounts"]]
  if (!is.null(geneCounts)){
    counts = ezMatrix(0, rows=names(geneCounts), cols=names(resultList))
    for (i in 1:length(resultList)){
      counts[ ,i] = resultList[[i]][["geneCounts"]][rownames(counts)]
    }
    seqAnno = ezFeatureAnnotation(param, rownames(counts), "gene")
    rawData = list(counts=counts, isLog=FALSE,
                   presentFlag=counts > param$sigThresh, 
                   seqAnno=seqAnno, featureLevel="gene",
                   type="Counts", countName="multiMatchCounts")
    if (is.null(param$normMethod)){
      param$normMethod = "logMean"
    }
    if (!ezIsSpecified(param$runGO)){
      param$runGO = TRUE
    }
    setwdNew("Count_QC")
    rawData$signal = ezNorm(rawData$counts, presentFlag=rawData$presentFlag, method=param$normMethod)
    runNgsCountQC(dataset, "00index.html", param, rawData=rawData)
    setwd("..")
    ezWrite('<p><a href="Count_QC/00index.html" title="Count QC Report">Count QC Report</a></p>', con=html)
  }
  
  if(!is.null(names(resultList[[1]][["Junction"]]))){
    junctionMaxVal = numeric()
    for (nm in names(resultList[[1]][["Junction"]])){
      junctionMaxVal[nm] = 0
      for (sm in samples){
        junctionMaxVal[nm] = max(junctionMaxVal[nm], unlist(resultList[[sm]][["Junction"]][[nm]]))
      }
    }
    for(sm in samples){
      pngFiles = character()
      for(nm in names(resultList[[sm]][["Junction"]])){
        junctionPlot = resultList[[sm]][["Junction"]][[nm]]
        pngFile = ezValidFilename(paste(sm, "_", nm, ".png", sep=""))
        png(file=pngFile, width=600)
        #eval(parse(text=junctionPlot))
        if(nm %in% c("splice_events", "splice_junction")){
          pie(junctionPlot, col=c(2,3,4), init.angle=30,angle=c(60,120,150),density=c(70,70,70),main=nm, labels=paste(names(junctionPlot), paste(round(junctionPlot), "%", sep="")))
        }else if(nm =="junctionSaturation"){
          x = as.numeric(names(junctionPlot[[1]])) * 100
          plot(1,1,xlab="percent of total reads", ylab='Number of splicing junctions (x1000)',type='o',
               ylim=c(0, junctionMaxVal[nm]/1000), xlim=range(x))
          saturationColors = c("all junctions"="blue", "known junctions"="red", "novel junctions"="green")
          for(item in names(junctionPlot)){
            lines(x, junctionPlot[[item]]/1000, col=saturationColors[item], type="o")
          }
          legend("topleft", legend=names(saturationColors), col=saturationColors,lwd=1,pch=1)
        }
        dev.off()
        pngFiles[nm] = pngFile
      }
      plotBySamples[[sm]] = c(plotBySamples[[sm]], pngFiles)
      plotByStatistics[["Junction Plots"]] = c(plotByStatistics[["Junction Plots"]], pngFiles)
    }
    
    ## do the junction saturation plot in main page for all samples
    ezWrite("<h3>Junction saturation plot for all samples</h3>", con=html)
    for(nm in names(resultList[[1]][["Junction"]][["junctionSaturation"]])){
      pngFile = ezValidFilename(paste("junctionSaturation_", nm, ".png", sep=""))
      png(file=pngFile, width=700)
      plot(1,1,xlab="percent of total reads", ylab='Number of splicing junctions (x1000)',type='o', ylim=c(0, junctionMaxVal["junctionSaturation"]/1000), xlim=c(0, 130), main=nm)
      for(sm in samples){
        lines(x, resultList[[sm]][["Junction"]][["junctionSaturation"]][[nm]]/1000, col=sampleColors[sm], type="o")
      }
      legend("bottomright", legend=samples, col=sampleColors[samples], lwd=1, pch=1)
      dev.off()
      writeImageColumnToHtml(pngFile, con=html)
    }
  }
  
  ## write the resulys by statistics per page to the main pages
  ezWrite("<h2>The results plot by each statistics</h2>", con=html)
  tableOfPages = ezMatrix("", rows=names(plotByStatistics), cols="Plots")
  # replace the space with undersocre if available, otherwise some errors will occur in the html
  plotByStatisticsPages = paste(gsub("[[:space:]]+", "_", names(plotByStatistics)), ".html", sep="")
  for(i in 1:length(plotByStatistics)){
    tableOfPages[i,] = paste("<a href=", plotByStatisticsPages[i], ">", plotByStatisticsPages[i], "</a>", sep="")
    subHtml = openHtmlReport(plotByStatisticsPages[i], param=param, title=plotByStatisticsPages[i])
    ezWrite(paste("<h3>", names(plotByStatistics)[i], "</h3>", sep=""), con=subHtml)
    writeImageColumnToHtml(plotByStatistics[[i]], con=subHtml)
    closeHTML(subHtml)
  }
  writeTableToHtml(tableOfPages, con=html)
  
  ## write the reults by sample per page to the main pages
  ezWrite("<h2>The results plot by each sample</h2>", con=html)
  plotBySamplesPages = paste(gsub("[[:space:]]+", "_", names(plotBySamples)), ".html", sep="")
  tableOfPages = ezMatrix("", rows=names(plotBySamples), cols="Plots")
  for(i in 1:length(plotBySamples)){
    tableOfPages[i, ] = paste("<a href=", plotBySamplesPages[i], ">", plotBySamplesPages[i], "</a>", sep="")
    subHtml = openHtmlReport(plotBySamplesPages[i], param=param, title=plotBySamplesPages[i])
    ezWrite(paste("<h3>", names(plotBySamples)[i], "</h3>", sep=""), con=subHtml)
    writeImageColumnToHtml(plotBySamples[[i]], con=subHtml)
    closeHTML(subHtml)
  }
  writeTableToHtml(tableOfPages, con=html)
}





makeAlignmentCountBarPlot = function(file, mmCounts){
  multiCount = as.integer(colnames(mmCounts))
  isSmall = multiCount <= 3
  if (any(!isSmall)){
    mmCounts = cbind(mmCounts[ , isSmall, drop=FALSE], 
                     ">3"=rowSums(mmCounts[ , !isSmall, drop=FALSE]))
  }
  ezWrite.table(mmCounts, file=sub(".png", ".txt", file))
  multiCountColors = c("0 hit(s)"="gray", "1 hit(s)"="blue", "2 hit(s)"="cyan",
                       "3 hit(s)"="green", ">3 hit(s)"="orange")
  colnames(mmCounts) = paste(colnames(mmCounts), "hit(s)")
  stopifnot(colnames(mmCounts) %in% names(multiCountColors))
  png(file=file, width=400 + nrow(mmCounts) * 10, height=700)
  par(mar=c(12, 4.1, 4.1, 2.1))
  mmCounts = mmCounts[ , rev(colnames(mmCounts))]
  barplot(t(mmCounts)/1e6, las=2, ylab="Counts [Mio]", main="total alignments", legend.text=TRUE, border=NA,
          col=multiCountColors[colnames(mmCounts)], xlim=c(0, nrow(mmCounts) +5))
  #legend("topright", paste(colnames(mmCountShrink), "hit(s)", sep=""), col=multiCountColors[colnames(mmCountShrink)],
  #       cex=1.2, pch=20, bty="o", pt.bg="white")
  dev.off()
  return(file)
}



plotPosSpecificErrorRate = function(errorRate, png=NULL, main="Per base mismatch rate",
                                    writeTxt=TRUE){
  if (!is.null(png)){
    png(file=png, width=1600)
    par(mfrow=c(1,2))
    on.exit(dev.off())
    if (writeTxt){
      for(i in 1:length(errorRate)){
        ezWrite.table(errorRate[[i]], sub(".png$", paste("-",names(errorRate)[i], ".txt", sep=""), png))
      }
    }
  }
  trimmedClippedRateMatrix = rbind(errorRate[["trimmedRate"]], errorRate[["clippedRate"]])
  errorRateMatrix = errorRate[["errorRate"]] 
  colnames(trimmedClippedRateMatrix) = 1:ncol(trimmedClippedRateMatrix)
  barplot(trimmedClippedRateMatrix, col=c("darkorange", "blue"), space=0, border=NA,
          xlab="Base Position in Read", ylab="Trimmed-Clipped Rate", 
          main=paste(main, "trimmed-clipped rate"), ylim=c(0, 1), #max(0.1, 1.2*max(colSums(trimmedClippedRateMatrix)))), 
          xpd=FALSE)
  legend("top", c("trimmed", "clipped"), col=c("darkorange", "blue"), pch=20)
  yMax = max(0.1, max(errorRateMatrix, na.rm=TRUE))
  barCol = ifelse (yMax > 0.1, "red", "gray")
  barplot(errorRateMatrix, space=0, border=NA,
          xlab="Base Position in Read", ylab="Mismatch Rate",  
          main=paste(main, "mismatch rate"), ylim=c(0, yMax), col=barCol,
          xpd=FALSE)
  if(yMax > 0.1){
    warning("The error rate range is larger than 0.1")
  }
}
