IMAGE_NAME := second.pytorch
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
KITTI_DATASET_ROOT :=

.PHONY: build
build:
	docker build \
		-t $(IMAGE_NAME):latest .

.PHONY: prepare
prepare:
ifndef KITTI_DATASET_ROOT
	echo "argument KITTI_DATASET_ROOT is not defined"
	exit 1
endif
	mkdir -p $(KITTI_DATASET_ROOT)/training/velodyne_reduced && \
	mkdir -p $(KITTI_DATASET_ROOT)/testing/velodyne_reduced && \
	docker run --rm -it --gpus all \
		-v /hdd/kitti:/root/data \
		-v $(MAKEFILE_DIR)/model:/root/model \
		$(IMAGE_NAME):latest \
		python create_data.py kitti_data_prep --root_path=/root/data
       	
.PHONY: train
train:
ifndef KITTI_DATASET_ROOT
	echo "argument KITTI_DATASET_ROOT is not defined"
	exit 1
endif
	docker run --rm -it --gpus all \
		-v /hdd/kitti:/root/data \
		-v $(MAKEFILE_DIR)/model:/root/model \
		$(IMAGE_NAME):latest \
		python ./pytorch/train.py train \
			--config_path=./configs/pointpillars/car/xyres_16.config \
			--model_dir=/root/model/pointpillars-car-16