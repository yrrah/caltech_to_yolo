# caltech_to_yolo
convert caltech101 dataset to YOLO format

Run caltech101_to_yolo.m in the same directory as '101_ObjectCategories' and 'Annotations' after you extract them. 

It renames the mismatched folders, then creates the following...

images  
  -> eachclassname_####.jpg  
  -> ...  
labels  
  -> eachclassname_####.txt  
  -> ...  
caltech101.names  

