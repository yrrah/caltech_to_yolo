function caltech101_to_YOLO()
mkdir 'labels'
mkdir 'images'
new_image_names = ["faces", "faces_easy", "leopards", "motorbikes"];
old_image_names = ["Faces", "Faces_easy", "Leopards", "Motorbikes"];

for k = 1 : length(new_image_names)
    rename_dir("101_ObjectCategories", new_image_names{k}, old_image_names{k})
end

new_annotation_names = ["airplanes", "faces", "faces_easy", "leopards", "motorbikes"];
old_annotation_names = ["Airplanes_Side_2","Faces_2", "Faces_3", "Leopards", "Motorbikes_16"];

for k = 1 : length(new_annotation_names)
    rename_dir("Annotations", new_annotation_names{k}, old_annotation_names{k})
end

folders = dir('Annotations');
folders=folders(~ismember({folders.name},{'.','..'}));
dirFlags = [folders.isdir];
folders = folders(dirFlags);
classes = strings(size(folders));
folders = {folders.name};
[classes{:}] = folders{:};
classes = sort(classes,2);

fileID = fopen('caltech101.names','w');
for k = 1 : length(classes)
  fprintf(fileID,'%s\n', classes{k});
  class_members(k-1, classes{k});
end
fclose(fileID);

function rename_dir(dir_name, new_name, old_name)
new_file = fullfile(dir_name,new_name);
if ~exist(new_file, 'dir')
    movefile(fullfile(dir_name, old_name), new_file)
end

function class_members(class, class_name)
members = dir(fullfile('Annotations',class_name));
members=members(~ismember({members.name},{'.','..'}));

annotations = cellstr(vertcat(members.name));
[~,member_names,~] = cellfun(@fileparts,annotations,'uniformoutput',false);
split = vertcat(regexp(member_names, '_', 'split'));
temp = vertcat(split{:});
names = temp(:,2);
old_images = strcat('image_',names,'.jpg');
new_images = strcat(class_name,'_',names,'.jpg');
labels = strcat(class_name,'_',names,'.txt');

for k = 1 : length(member_names)
  convert_file(class, class_name, annotations{k}, old_images{k},  new_images{k}, labels{k});
end

function convert_file(class, class_name, annotation, old_image,  new_image, label)
%% move image file
old_img_file = fullfile('101_ObjectCategories', class_name, old_image);
new_img_file = fullfile('images',new_image);
copyfile(old_img_file, new_img_file);
 
%% load the annotated data
annotation_file = fullfile('Annotations', class_name, annotation);
load(annotation_file, 'box_coord', 'obj_contour');
   
%% convert box to YOLO
ima = imread(new_img_file); 
[ima_height, ima_width, ~] = size(ima);
label_file = fullfile('labels',label);
box_width = box_coord(4)-box_coord(3);
box_height = box_coord(2)-box_coord(1);
write_txt_annotation(label_file, class, (box_width/2+box_coord(3))/ima_width, (box_height/2+box_coord(1))/ima_height, box_width/ima_width, box_height/ima_height);

function write_txt_annotation(name, class, x, y, w, h)
fileID = fopen(name,'w');
fprintf(fileID,'%d %.20f %.20f %.20f %.20f\n',class, x, y, w, h);
fclose(fileID);
