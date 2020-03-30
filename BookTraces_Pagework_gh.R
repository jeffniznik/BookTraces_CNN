# This file contains code for how to prepare image folders and add new data
# from the HathiTrust Digital library
library(magick)
library(pdftools)
library(dplyr)

my_pdf_readR<-function(filestring){
  image_read_pdf(filestring,density=72)[-1]
}

mult_pdf_readR<-function(filestring_vector){
  do.call("c",sapply(filestring_vector,my_pdf_readR))
}

# The following is a start to finish example of reading in files and downloading 
# greyscale images of the correct size into the right folders (training, testing,
# and validation). It begins with descriptions of titles and which pages conatin
# marginalia, which we keep track of so the image goes into its NoMarginalia or,
# Marginalia subfolder.

##################### round 6 #######################################
# A short historical grammar of the German language /    53 long, first 33 marg
# Elementary Russian grammar, by E. Prokosch ... Prokosch, 5 long, 5th marg
# Sochineniia Pushkina, s prilozheniem materialo 10 long all marg
#  ""                                         20 no marg
# Aegyptisches glossar; die haufigeren worte der aegyptischen 18, first 9 marg
# Critical grammar of the Hebrew language / by   8 long first 4 marg
# Gesenius' Hebrew grammar. 2 long, 2nd marg
# Manual de linguas indígenas de Angola : segundo 16 all marg
# ""    same but no marg
# Aristotle's treatise on rhetoric, literally tr.  6 long first 3 marg
# Geschiedenis van den Amsterdamschen   14, first 7 marg
# A study of prose fiction / by Bliss Perry.  24 long, 1,2,15:24 marg
# Stories from the Italian poets: being   22 long, last 11 marg
#
#

r6_strings<-c("uva.x001173679-3-14-20-21-25-34-35-37-39-41-42-44-70-77-80-82-89-93-95-97-99-115-117-119-127-128-130-131-133-137-155-157-167-169-182-185-193-195-198-201-203-204-206-208-210-211-1583897906.pdf",
              "uva.x000306210-2-6-8-9-19-1584283497.pdf",
              "uva.x001168507-5-7-9-45-457-491-493-496-497-1584285740.pdf",
              "uva.x001168507-13-15-17-22-24-27-31-33-50-468-469-472-478-482-485-487-490-1584290522.pdf",
              "uva.x000360270-14-17-26-68-81-87-101-110-135-136-140-142-143-145-149-153-173-181-1584323296.pdf",
              "uva.x001168317-2-3-7-44-52-55-56-58-1584329373.pdf",
              "uva.x004758045-6-7-1584365819.pdf",
              "uva.x000068898-5-7-9-30-36-57-71-78-81-88-89-150-151-153-224-226-1584367096.pdf",
              "uva.x000068898-3-4-6-10-13-17-20-23-59-75-98-134-145-249-262-265-1584368604.pdf",
              "uva.x001023880-9-11-30-32-42-1584377693.pdf",
              "uva.x000051405-89-93-128-132-137-139-152-154-157-160-162-355-1584381201.pdf",
              "uva.x030756597-2-4-7-22-25-27-30-32-37-41-43-46-56-66-77-155-173-223-321-367-420-421-424-440-1584391221.pdf",
              "uva.x000764251-2-9-12-19-25-201-203-227-270-274-289-439-473-474-478-507-508-512-513-522-524-528-1584397717.pdf"
              
)

r6_has_marginalia<-numeric(214)
r6_has_marginalia[c(1:33,58,59:68,89:97,107:110,116:132,149:151,155:161,169,170,
                    183:192,204:214)]<-1

r6_pages<-mult_pdf_readR(r6_strings)
r6_pages_adj<-image_quantize(r6_pages,colorspace = 'gray')
r6_pages_adj<-image_scale(r6_pages_adj,"306")
r6_pages_adj<-image_crop(r6_pages_adj, "286x396+20") # "+20" removes left border
                                                     # of text (from Hathi)


# Randomize training/validation folders, but keep ratios the same
rand_inxs<-sample(c(1:107),80) 
# set wd to  folder, Marginalia
for (i in 1:80){
  r6_pages_adj[which(r6_has_marginalia==1)][rand_inxs][i] %>% image_write(., path = paste0("r6_page",i,".png"), format = "png")
}
for (i in 1:27){
  r6_pages_adj[which(r6_has_marginalia==1)][-rand_inxs][i] %>% image_write(., path = paste0("vr6_page",i,".png"), format = "png")
} 
# set wd to  folder, NoMarginalia
for (i in 1:80){
  r6_pages_adj[which(r6_has_marginalia==0)][rand_inxs][i] %>% image_write(., path = paste0("r6_page",i,".png"), format = "png")
}
for (i in 1:27){
  r6_pages_adj[which(r6_has_marginalia==0)][-rand_inxs][i] %>% image_write(., path = paste0("vr6_page",i,".png"), format = "png")
} 
