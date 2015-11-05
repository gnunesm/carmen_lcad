/* Auto-generated by genmsg_cpp for file /home/rcnascimento/ros/bumblebee_basic/msg/bumblebee_basic_stereoimage.msg */
#ifndef BUMBLEBEE_BASIC_MESSAGE_BUMBLEBEE_BASIC_STEREOIMAGE_H
#define BUMBLEBEE_BASIC_MESSAGE_BUMBLEBEE_BASIC_STEREOIMAGE_H
#include <string>
#include <vector>
#include <map>
#include <ostream>
#include "ros/serialization.h"
#include "ros/builtin_message_traits.h"
#include "ros/message_operations.h"
#include "ros/time.h"

#include "ros/macros.h"

#include "ros/assert.h"

#include "std_msgs/Header.h"

namespace bumblebee_basic
{
template <class ContainerAllocator>
struct bumblebee_basic_stereoimage_ {
  typedef bumblebee_basic_stereoimage_<ContainerAllocator> Type;

  bumblebee_basic_stereoimage_()
  : header()
  , width(0)
  , height(0)
  , image_size(0)
  , isRectified(0)
  , raw_left()
  , raw_right()
  {
  }

  bumblebee_basic_stereoimage_(const ContainerAllocator& _alloc)
  : header(_alloc)
  , width(0)
  , height(0)
  , image_size(0)
  , isRectified(0)
  , raw_left(_alloc)
  , raw_right(_alloc)
  {
  }

  typedef  ::std_msgs::Header_<ContainerAllocator>  _header_type;
   ::std_msgs::Header_<ContainerAllocator>  header;

  typedef uint32_t _width_type;
  uint32_t width;

  typedef uint32_t _height_type;
  uint32_t height;

  typedef uint32_t _image_size_type;
  uint32_t image_size;

  typedef int32_t _isRectified_type;
  int32_t isRectified;

  typedef std::vector<uint8_t, typename ContainerAllocator::template rebind<uint8_t>::other >  _raw_left_type;
  std::vector<uint8_t, typename ContainerAllocator::template rebind<uint8_t>::other >  raw_left;

  typedef std::vector<uint8_t, typename ContainerAllocator::template rebind<uint8_t>::other >  _raw_right_type;
  std::vector<uint8_t, typename ContainerAllocator::template rebind<uint8_t>::other >  raw_right;


  typedef boost::shared_ptr< ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator> > Ptr;
  typedef boost::shared_ptr< ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator>  const> ConstPtr;
  boost::shared_ptr<std::map<std::string, std::string> > __connection_header;
}; // struct bumblebee_basic_stereoimage
typedef  ::bumblebee_basic::bumblebee_basic_stereoimage_<std::allocator<void> > bumblebee_basic_stereoimage;

typedef boost::shared_ptr< ::bumblebee_basic::bumblebee_basic_stereoimage> bumblebee_basic_stereoimagePtr;
typedef boost::shared_ptr< ::bumblebee_basic::bumblebee_basic_stereoimage const> bumblebee_basic_stereoimageConstPtr;


template<typename ContainerAllocator>
std::ostream& operator<<(std::ostream& s, const  ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator> & v)
{
  ros::message_operations::Printer< ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator> >::stream(s, "", v);
  return s;}

} // namespace bumblebee_basic

namespace ros
{
namespace message_traits
{
template<class ContainerAllocator> struct IsMessage< ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator> > : public TrueType {};
template<class ContainerAllocator> struct IsMessage< ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator>  const> : public TrueType {};
template<class ContainerAllocator>
struct MD5Sum< ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator> > {
  static const char* value() 
  {
    return "fb0d00fb771d75df4f0e936155d3fcf0";
  }

  static const char* value(const  ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator> &) { return value(); } 
  static const uint64_t static_value1 = 0xfb0d00fb771d75dfULL;
  static const uint64_t static_value2 = 0x4f0e936155d3fcf0ULL;
};

template<class ContainerAllocator>
struct DataType< ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator> > {
  static const char* value() 
  {
    return "bumblebee_basic/bumblebee_basic_stereoimage";
  }

  static const char* value(const  ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator> &) { return value(); } 
};

template<class ContainerAllocator>
struct Definition< ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator> > {
  static const char* value() 
  {
    return "Header header\n\
uint32 width           #<The x dimension of the image in pixels.\n\
uint32 height          #<The y dimension of the image in pixels. \n\
uint32 image_size       #<width*height*bytes_per_pixel. \n\
int32 isRectified\n\
uint8[] raw_left\n\
uint8[] raw_right\n\
\n\
================================================================================\n\
MSG: std_msgs/Header\n\
# Standard metadata for higher-level stamped data types.\n\
# This is generally used to communicate timestamped data \n\
# in a particular coordinate frame.\n\
# \n\
# sequence ID: consecutively increasing ID \n\
uint32 seq\n\
#Two-integer timestamp that is expressed as:\n\
# * stamp.secs: seconds (stamp_secs) since epoch\n\
# * stamp.nsecs: nanoseconds since stamp_secs\n\
# time-handling sugar is provided by the client library\n\
time stamp\n\
#Frame this data is associated with\n\
# 0: no frame\n\
# 1: global frame\n\
string frame_id\n\
\n\
";
  }

  static const char* value(const  ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator> &) { return value(); } 
};

template<class ContainerAllocator> struct HasHeader< ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator> > : public TrueType {};
template<class ContainerAllocator> struct HasHeader< const ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator> > : public TrueType {};
} // namespace message_traits
} // namespace ros

namespace ros
{
namespace serialization
{

template<class ContainerAllocator> struct Serializer< ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator> >
{
  template<typename Stream, typename T> inline static void allInOne(Stream& stream, T m)
  {
    stream.next(m.header);
    stream.next(m.width);
    stream.next(m.height);
    stream.next(m.image_size);
    stream.next(m.isRectified);
    stream.next(m.raw_left);
    stream.next(m.raw_right);
  }

  ROS_DECLARE_ALLINONE_SERIALIZER;
}; // struct bumblebee_basic_stereoimage_
} // namespace serialization
} // namespace ros

namespace ros
{
namespace message_operations
{

template<class ContainerAllocator>
struct Printer< ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator> >
{
  template<typename Stream> static void stream(Stream& s, const std::string& indent, const  ::bumblebee_basic::bumblebee_basic_stereoimage_<ContainerAllocator> & v) 
  {
    s << indent << "header: ";
s << std::endl;
    Printer< ::std_msgs::Header_<ContainerAllocator> >::stream(s, indent + "  ", v.header);
    s << indent << "width: ";
    Printer<uint32_t>::stream(s, indent + "  ", v.width);
    s << indent << "height: ";
    Printer<uint32_t>::stream(s, indent + "  ", v.height);
    s << indent << "image_size: ";
    Printer<uint32_t>::stream(s, indent + "  ", v.image_size);
    s << indent << "isRectified: ";
    Printer<int32_t>::stream(s, indent + "  ", v.isRectified);
    s << indent << "raw_left[]" << std::endl;
    for (size_t i = 0; i < v.raw_left.size(); ++i)
    {
      s << indent << "  raw_left[" << i << "]: ";
      Printer<uint8_t>::stream(s, indent + "  ", v.raw_left[i]);
    }
    s << indent << "raw_right[]" << std::endl;
    for (size_t i = 0; i < v.raw_right.size(); ++i)
    {
      s << indent << "  raw_right[" << i << "]: ";
      Printer<uint8_t>::stream(s, indent + "  ", v.raw_right[i]);
    }
  }
};


} // namespace message_operations
} // namespace ros

#endif // BUMBLEBEE_BASIC_MESSAGE_BUMBLEBEE_BASIC_STEREOIMAGE_H

