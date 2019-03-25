
#include <opencv/cv.h>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <pcl/visualization/pcl_visualizer.h>
#include <pcl/io/ply_io.h>
#include <pcl/visualization/cloud_viewer.h>
#include <pcl/ModelCoefficients.h>
#include <pcl/io/pcd_io.h>
#include <pcl/point_types.h>
#include <pcl/sample_consensus/method_types.h>
#include <pcl/sample_consensus/model_types.h>
#include <pcl/segmentation/sac_segmentation.h>
#include <pcl/filters/voxel_grid.h>
#include <pcl/filters/extract_indices.h>

#include "velodyne_camera_calibration.h"

using namespace std;
using namespace pcl;

int bumblebee_received = 0;

int number  = 0;

int camera_number;

carmen_bumblebee_basic_stereoimage_message bumblebee_message;

static carmen_pose_3D_t camera_pose; // Camera pose in relation to sensor board
static carmen_pose_3D_t velodyne_pose; //velodyne pose in relation to sensor board

static carmen_camera_parameters camera_parameters;

double velodyne_vertical_angles[32] =
{
		-30.6700000, -29.3300000, -28.0000000, -26.6700000, -25.3300000, -24.0000000, -22.6700000, -21.3300000,
		-20.0000000, -18.6700000, -17.3300000, -16.0000000, -14.6700000, -13.3300000, -12.0000000, -10.6700000,
		-9.3299999, -8.0000000, -6.6700001, -5.3299999, -4.0000000, -2.6700001, -1.3300000, 0.0000000, 1.3300000,
		2.6700001, 4.0000000, 5.3299999, 6.6700001, 8.0000000, 9.3299999, 10.6700000
};

int velodyne_ray_order2[32] = {0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31};

PointXYZ
compute_pointxyz_from_velodyne(double v_angle, double h_angle, double radius)
{
    // build a new point
    PointXYZ point;

	double cos_rot_angle = cos(h_angle);
	double sin_rot_angle = sin(h_angle);

	double cos_vert_angle = cos(v_angle);
	double sin_vert_angle = sin(v_angle);

	double xy_distance = radius * cos_vert_angle;

	point.x = (xy_distance * cos_rot_angle);
	point.y = (xy_distance * sin_rot_angle);
	point.z = (radius * sin_vert_angle);

    return point;
}

void
process_key_input(char k)
{
    static double step_size = 0.01;
    static double angular_step_size = 0.5;

    // Nao foi utilizado um switch case por questao de legibilidade do codigo, dessa maneira ele fica mais compacto e
    // simples de ler
    if (k == 'q') camera_pose.position.x += step_size;
    if (k == 'a') camera_pose.position.x -= step_size;
    if (k == 'w') camera_pose.position.y += step_size;
    if (k == 's') camera_pose.position.y -= step_size;
    if (k == 'e') camera_pose.position.z += step_size;
    if (k == 'd') camera_pose.position.z -= step_size;

    if (k == 'r') camera_pose.orientation.roll += carmen_degrees_to_radians(angular_step_size);
    if (k == 'f') camera_pose.orientation.roll -= carmen_degrees_to_radians(angular_step_size);
    if (k == 't') camera_pose.orientation.pitch += carmen_degrees_to_radians(angular_step_size);
    if (k == 'g') camera_pose.orientation.pitch -= carmen_degrees_to_radians(angular_step_size);
    if (k == 'y') camera_pose.orientation.yaw += carmen_degrees_to_radians(angular_step_size);
    if (k == 'h') camera_pose.orientation.yaw -= carmen_degrees_to_radians(angular_step_size);

    if (k == 'u') camera_parameters.fx_factor += step_size;
    if (k == 'j') camera_parameters.fx_factor -= step_size;

    if (k == 'i') camera_parameters.fy_factor += step_size;
    if (k == 'k') camera_parameters.fy_factor -= step_size;

    if(k == 'z') step_size = step_size / 10.0;
    if(k == 'x') step_size = step_size * 10.0;

    if(k == 'n') angular_step_size = angular_step_size / 10.0;
    if(k == 'm') angular_step_size = angular_step_size * 10.0;


    if (k == 'q' || k == 'a' || k == 'w' || k == 's' || k == 'e' || k == 'd' ||
        k == 'r' || k == 'f' || k == 't' || k == 'g' || k == 'y' || k == 'h' ||
        k == 'u' || k == 'j' || k == 'i' || k == 'k')
    {
        printf("\nCAM POSE:\n\tx:%lf y:%lf z:%lf\n",
               camera_pose.position.x, camera_pose.position.y, camera_pose.position.z);
        printf("\troll: %lf pitch: %lf yaw: %lf\n",
               camera_pose.orientation.roll, camera_pose.orientation.pitch, camera_pose.orientation.yaw);
        printf("\tfx: %lf, fy:%lf\n", camera_parameters.fx_factor, camera_parameters.fy_factor);
    }

    if(k == 'z' || k == 'x')
        printf("\nValor do passo alterado para: %lf\n", step_size);

    if(k == 'm' || k == 'n')
        printf("\nValor do passo angular alterado para: %lf\n", angular_step_size);

}


void
show_velodyne(carmen_velodyne_partial_scan_message *velodyne_message)
{
    if (!bumblebee_received)
        return;

    cv::Mat camera_image(cv::Size(bumblebee_message.width, bumblebee_message.height), CV_8UC3, bumblebee_message.raw_right);
    cv::Mat camera_image_show(cv::Size(bumblebee_message.width, bumblebee_message.height), CV_8UC3);

    cv::cvtColor(camera_image,camera_image_show, CV_RGB2BGR);

    std::vector<carmen_velodyne_points_in_cam_t> points_in_cam = carmen_velodyne_camera_calibration_lasers_points_in_camera(velodyne_message, camera_parameters,
                                                                                                                            velodyne_pose, camera_pose,
                                                                                                                            bumblebee_message.width,
                                                                                                                            bumblebee_message.height);

    for(unsigned int i = 0; i < points_in_cam.size(); i++)
    {
        float r = 0;

        r = points_in_cam.at(i).laser_polar.length / 50.0;
        r *= 255;
        r = 255 - r;

        cv::circle(camera_image_show,cv::Point(points_in_cam.at(i).ipx,points_in_cam.at(i).ipy),2,cv::Scalar(0,0,r));
    }

    cv::imshow("Camera with points", camera_image_show);

    char k = cv::waitKey(5);
    process_key_input(k);

}


///////////////////////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                           //
// Handlers                                                                                  //
//                                                                                           //
///////////////////////////////////////////////////////////////////////////////////////////////

void
bumblebee_basic_image_handler(carmen_bumblebee_basic_stereoimage_message *bumblebee_basic_message __attribute__ ((unused)))
{
	bumblebee_received = 1;
}


void
velodyne_partial_scan_message_handler(carmen_velodyne_partial_scan_message *velodyne_message)
{
    // carmen_velodyne_camera_calibration_arrange_velodyne_vertical_angles_to_true_position(velodyne_message);
	// show_velodyne(velodyne_message);

    double h_angle, v_angle;
	unsigned short distances[32];
	double range;

    pcl::PointCloud<pcl::PointXYZ>::Ptr cloud (new pcl::PointCloud<pcl::PointXYZ>), cloud_p (new pcl::PointCloud<pcl::PointXYZ>), cloud_f (new pcl::PointCloud<pcl::PointXYZ>),  cloud_filtered (new pcl::PointCloud<pcl::PointXYZ>);  // Fill in the cloud data

    for(int i=0; i<velodyne_message->number_of_32_laser_shots; i++) {
        h_angle = velodyne_message->partial_scan[i].angle;
	    for(int j=0; j<32; j++) {
            distances[j] = velodyne_message->partial_scan[i].distance[j];
        }
        h_angle = M_PI * h_angle / 180.;
        
        for (int j = 0; j < 32; j++)
            // pritf("%d  ", velodyne_message->partial_scan[i].distance[j]);
	    {
	    	range = (double) distances[velodyne_ray_order2[j]] / 500.;
	    	v_angle = velodyne_vertical_angles[j];
	    	v_angle = M_PI * v_angle / 180.;

	    	PointXYZ point = compute_pointxyz_from_velodyne(v_angle, -h_angle, range);
	    	cloud->push_back(point);
	    }
	}

    // // Create the filtering object: downsample the dataset using a leaf size of 1cm
    // pcl::VoxelGrid<pcl::PointXYZ> sor;
    // sor.setInputCloud (cloud);
    // sor.setLeafSize (0.1f, 0.1f, 0.1f);
    // sor.filter (*cloud_filtered);

    // // Convert to the templated PointCloud
    // // pcl::fromPCLPointCloud2 (*cloud_filtered_blob, *cloud_filtered);

    // pcl::ModelCoefficients::Ptr coefficients (new pcl::ModelCoefficients ());
    // pcl::PointIndices::Ptr inliers (new pcl::PointIndices ());
    // // Create the segmentation object
    // pcl::SACSegmentation<pcl::PointXYZ> seg;
    // // Optional
    // seg.setOptimizeCoefficients (true);
    // // Mandatory
    // seg.setModelType (pcl::SACMODEL_PLANE);
    // seg.setMethodType (pcl::SAC_RANSAC);
    // seg.setMaxIterations (1000);
    // seg.setDistanceThreshold (0.01);

    // // Create the filtering object
    // pcl::ExtractIndices<pcl::PointXYZ> extract;

    // int i = 0, nr_points = (int) cloud_filtered->points.size ();
    // // While 30% of the original cloud is still there
    // while (cloud_filtered->points.size () > 0.3 * nr_points)
    // {
    //     // printf("aqui\n");
    //     // Segment the largest planar component from the remaining cloud
    //     seg.setInputCloud (cloud_filtered);
    //     seg.segment (*inliers, *coefficients);
    //     if (inliers->indices.size () == 0)
    //     {
    //     std::cerr << "Could not estimate a planar model for the given dataset." << std::endl;
    //     break;
    //     }

    //     // Extract the inliers
    //     extract.setInputCloud (cloud_filtered);
    //     extract.setIndices (inliers);
    //     extract.setNegative (false);
    //     extract.filter (*cloud_p);
    // }

    // visualization::CloudViewer viewer ("Simple Cloud Viewer");
    // viewer.showCloud (cloud_p);
    // while (!viewer.wasStopped ())
    // {
    //     // boost::this_thread::sleep (boost::posix_time::microseconds (100));
    // }

    pcl::PCDWriter writer;
    std::stringstream ss;
    ss << "cloud_" << number << ".pcd";
    writer.write<pcl::PointXYZ> (ss.str (), *cloud, false);
    number++;
}


///////////////////////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                           //
// Initializations                                                                           //
//                                                                                           //
///////////////////////////////////////////////////////////////////////////////////////////////

static void
shutdown_module(int signo)
{
    if (signo == SIGINT)
    {
        carmen_ipc_disconnect();
        fprintf(stderr, "\nShutdown velodyne_camera_calibration\n");

        exit(0);
    }
}


static void
subscribe_to_ipc_messages()
{
    carmen_bumblebee_basic_subscribe_stereoimage(camera_number, &bumblebee_message,
                                                 (carmen_handler_t) bumblebee_basic_image_handler, CARMEN_SUBSCRIBE_LATEST);

    carmen_velodyne_subscribe_partial_scan_message(NULL,
                                                   (carmen_handler_t)velodyne_partial_scan_message_handler,
                                                   CARMEN_SUBSCRIBE_LATEST);

}

int
read_parameters(int argc, char **argv)
{

    if ((argc != 2))
        carmen_die("%s: Wrong number of parameters. This module requires 1 parameter and received %d parameter(s). \nUsage:\n %s <camera_number>",
                   argv[0], argc - 1, argv[0]);

    /* defining the camera to be used */
    camera_number = atoi(argv[1]);

    int num_items;
	char bumblebee_string[256];
    char camera_string[256];

	sprintf(bumblebee_string, "%s%d", "bumblebee_basic", camera_number);
    sprintf(camera_string, "%s%d", "camera", camera_number);

	carmen_param_t param_list[] = {

            { bumblebee_string, (char*) "fx", CARMEN_PARAM_DOUBLE, &camera_parameters.fx_factor, 0, NULL },
            { bumblebee_string, (char*) "fy", CARMEN_PARAM_DOUBLE, &camera_parameters.fy_factor, 0, NULL },
            { bumblebee_string, (char*) "cu", CARMEN_PARAM_DOUBLE, &camera_parameters.cu_factor, 0, NULL },
            { bumblebee_string, (char*) "cv", CARMEN_PARAM_DOUBLE, &camera_parameters.cv_factor, 0, NULL },
            { bumblebee_string, (char*) "pixel_size", CARMEN_PARAM_DOUBLE, &camera_parameters.pixel_size, 0, NULL },

            {(char *) "velodyne",  (char *) "x", CARMEN_PARAM_DOUBLE, &(velodyne_pose.position.x), 0, NULL},
            {(char *) "velodyne",  (char *) "y", CARMEN_PARAM_DOUBLE, &(velodyne_pose.position.y), 0, NULL},
            {(char *) "velodyne",  (char *) "z", CARMEN_PARAM_DOUBLE, &(velodyne_pose.position.z), 0, NULL},
            {(char *) "velodyne",  (char *) "roll", CARMEN_PARAM_DOUBLE, &(velodyne_pose.orientation.roll), 0, NULL},
            {(char *) "velodyne",  (char *) "pitch", CARMEN_PARAM_DOUBLE, &(velodyne_pose.orientation.pitch), 0, NULL},
            {(char *) "velodyne",  (char *) "yaw", CARMEN_PARAM_DOUBLE, &(velodyne_pose.orientation.yaw), 0, NULL},

            { camera_string, (char*) "x", CARMEN_PARAM_DOUBLE, &camera_pose.position.x, 0, NULL },
            { camera_string, (char*) "y", CARMEN_PARAM_DOUBLE, &camera_pose.position.y, 0, NULL },
            { camera_string, (char*) "z", CARMEN_PARAM_DOUBLE, &camera_pose.position.z, 0, NULL },
            { camera_string, (char*) "roll", CARMEN_PARAM_DOUBLE, &camera_pose.orientation.roll, 0, NULL },
            { camera_string, (char*) "pitch", CARMEN_PARAM_DOUBLE, &camera_pose.orientation.pitch, 0, NULL },
            { camera_string, (char*) "yaw", CARMEN_PARAM_DOUBLE, &camera_pose.orientation.yaw, 0, NULL }

    };


	num_items = sizeof(param_list) / sizeof(param_list[0]);
	carmen_param_install_params(argc, argv, param_list, num_items);

	return 0;
}


//////////////////////////////////////////////////////////////////////////////////////////////////

int
main(int argc, char **argv)
{
	/* Connect to IPC Server */
	carmen_ipc_initialize(argc, argv);

	/* Check the param server version */
	carmen_param_check_version(argv[0]);

	/* Register shutdown cleaner handler */
	signal(SIGINT, shutdown_module);

    /* Initialize all the relevant parameters */
    read_parameters(argc, argv);

    /* Subscribe to relevant messages */
    subscribe_to_ipc_messages();

	carmen_ipc_dispatch();

	return 0;
}

