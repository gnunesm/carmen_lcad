#ifndef XSENS_XYZ_HANDLER_H
#define XSENS_XYZ_HANDLER_H

#ifdef __cplusplus
extern "C" {
#endif

#define XSENS_SENSOR_VECTOR_SIZE 500
#define GPS_SENSOR_VECTOR_SIZE 500
#define XSENS_MTI_SENSOR_VECTOR_SIZE 500

#include "fused_odometry.h"
typedef struct 
{
	carmen_pose_3D_t xsens_pose;
	carmen_orientation_3D_t orientation;
	carmen_orientation_3D_t ang_velocity;

	carmen_pose_3D_t gps_pose;

	carmen_pose_3D_t sensor_board_pose;
	
	double last_xsens_message_timestamp;
	
	int initial_state_initialized;
	
	int extra_gps;
} xsens_xyz_handler;


typedef struct
{
	carmen_vector_3D_t acceleration;
	carmen_orientation_3D_t orientation;
	carmen_orientation_3D_t ang_velocity;
	carmen_vector_3D_t position;

	carmen_orientation_3D_t orientation_std_error;
	carmen_vector_3D_t position_std_error;

	double timestamp;
} sensor_vector_xsens_xyz;

xsens_xyz_handler *create_xsens_xyz_handler(int argc, char **argv, carmen_fused_odometry_parameters *fused_odometry_parameters);
void reset_xsens_xyz_handler(xsens_xyz_handler *xsens_handler);
void destroy_xsens_xyz_handler(xsens_xyz_handler *xsens_handler);
int is_global_pos_initialized();

#ifdef __cplusplus
}
#endif

#endif
