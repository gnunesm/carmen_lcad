
#ifndef _SEGMAP_CAR_CONFIG_H_
#define _SEGMAP_CAR_CONFIG_H_

#include "Eigen/Core"
#include "segmap_util.h"


using namespace Eigen;


#define distance_between_rear_wheels 1.535
#define distance_between_front_and_rear_axles 2.625
#define distance_between_front_car_and_front_wheels 0.85
#define distance_between_rear_car_and_rear_wheels 0.96
#define car_length (distance_between_front_and_rear_axles + distance_between_rear_car_and_rear_wheels + distance_between_front_car_and_front_wheels)
#define car_width distance_between_rear_wheels
#define center_to_rear_axis car_length / 2. - distance_between_rear_car_and_rear_wheels


Matrix<double, 3, 4> kitti_velodyne_to_cam();
Matrix<double, 3, 4> carmen_velodyne_to_cam3(int image_width = 1280, int image_height = 960);
Matrix<double, 4, 4> carmen_vel2car();


#endif
