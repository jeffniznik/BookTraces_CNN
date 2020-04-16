library(keras)
library(reticulate)
library(tensorflow)
library(dplyr)

# Data augmentation - creates more examples of your data by slightly modifying it
train_data_gen<-image_data_generator(
  rescale = 1/255,
  rotation_range = 2,           # +- 2 degrees
  width_shift_range = 0.03,     # +- 3% 
  height_shift_range = 0.03,
  # #zoom_range = 0.1,
  # horizontal_flip = TRUE,
  fill_mode = "nearest")
train_array_gen3<-flow_images_from_directory(
  "C:/Users/jniz2.000/Downloads/BookTraces/page_scans",
  generator=train_data_gen,
  target_size=c(396,286),
  color_mode="rgb",
  classes=c("Marginalia","NoMarginalia"),
  class_mode="binary")
#save_to_dir = "pages")   # can be used to see output of altered images
#save_prefix="a")         # ^

validation_data_gen<-image_data_generator(rescale = 1/255) # not augmented
validation_array_gen2<-flow_images_from_directory(
  "C:/Users/jniz2.000/Downloads/BookTraces/page_scans_vld",
  generator=validation_data_gen,
  target_size=c(396,286),
  color_mode="rgb",
  classes=c("Marginalia","NoMarginalia"),
  class_mode="binary")

conv_base <- application_vgg16(               # pretrained with vgg16
  weights = "imagenet",
  include_top = FALSE,
  input_shape = c(396,286,3))

model_pt16_3 <- keras_model_sequential() %>% 
  conv_base %>% 
  layer_flatten() %>% 
  layer_dense(units = 128, activation = "relu") %>% 
  layer_dense(units = 1, activation = "sigmoid")

freeze_weights(conv_base)

# Replicates the model on 8 GPUs.
parallel_model <- multi_gpu_model(model_pt16_3, gpus = 8)
parallel_model %>% compile(
  loss = "binary_crossentropy",
  optimizer = optimizer_rmsprop(lr = 2e-5),
  metrics = c("accuracy")
)

history <- parallel_model %>% fit_generator(
  train_array_gen3,
  steps_per_epoch = 90,
  epochs = 8,     # will be increased for ||computing, watching for overfitting 
  validation_data = validation_array_gen2,
  validation_steps = 45,
  workers = 8 # for 8 GPUs
)

# Results 
test_generator<-flow_images_from_directory(
  "C:/Users/jniz2.000/Downloads/BookTraces/page_scans_test",
  generator=image_data_generator(rescale = 1/255),
  target_size=c(396,286),
  color_mode="rgb",
  batch_size = 20,
  classes=c("Marginalia","NoMarginalia"),
  class_mode="binary"
)
model_pt16_3 %>% evaluate_generator(test_generator,steps=400/20) # 84% - best to date
