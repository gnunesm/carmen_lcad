/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class IPC_formatters */

#ifndef _Included_IPC_formatters
#define _Included_IPC_formatters
#ifdef __cplusplus
extern "C" {
#endif
#undef IPC_formatters_PrimitiveFMT
#define IPC_formatters_PrimitiveFMT 0L
#undef IPC_formatters_LengthFMT
#define IPC_formatters_LengthFMT 1L
#undef IPC_formatters_StructFMT
#define IPC_formatters_StructFMT 2L
#undef IPC_formatters_PointerFMT
#define IPC_formatters_PointerFMT 3L
#undef IPC_formatters_FixedArrayFMT
#define IPC_formatters_FixedArrayFMT 4L
#undef IPC_formatters_VarArrayFMT
#define IPC_formatters_VarArrayFMT 5L
#undef IPC_formatters_BadFormatFMT
#define IPC_formatters_BadFormatFMT 6L
#undef IPC_formatters_NamedFMT
#define IPC_formatters_NamedFMT 7L
#undef IPC_formatters_EnumFMT
#define IPC_formatters_EnumFMT 8L
/*
 * Class:     IPC_formatters
 * Method:    formatType
 * Signature: (J)I
 */
JNIEXPORT jint JNICALL Java_IPC_formatters_formatType
  (JNIEnv *, jclass, jlong);

/*
 * Class:     IPC_formatters
 * Method:    formatPrimitiveProc
 * Signature: (J)I
 */
JNIEXPORT jint JNICALL Java_IPC_formatters_formatPrimitiveProc
  (JNIEnv *, jclass, jlong);

/*
 * Class:     IPC_formatters
 * Method:    formatChoosePtrFormat
 * Signature: (JJ)J
 */
JNIEXPORT jlong JNICALL Java_IPC_formatters_formatChoosePtrFormat
  (JNIEnv *, jclass, jlong, jlong);

/*
 * Class:     IPC_formatters
 * Method:    formatFormatArray
 * Signature: (J)J
 */
JNIEXPORT jlong JNICALL Java_IPC_formatters_formatFormatArray
  (JNIEnv *, jclass, jlong);

/*
 * Class:     IPC_formatters
 * Method:    formatFormatArrayMax
 * Signature: (J)I
 */
JNIEXPORT jint JNICALL Java_IPC_formatters_formatFormatArrayMax
  (JNIEnv *, jclass, jlong);

/*
 * Class:     IPC_formatters
 * Method:    formatFormatArrayItemPtr
 * Signature: (JI)J
 */
JNIEXPORT jlong JNICALL Java_IPC_formatters_formatFormatArrayItemPtr
  (JNIEnv *, jclass, jlong, jint);

/*
 * Class:     IPC_formatters
 * Method:    formatFormatArrayItemInt
 * Signature: (JI)I
 */
JNIEXPORT jint JNICALL Java_IPC_formatters_formatFormatArrayItemInt
  (JNIEnv *, jclass, jlong, jint);

/*
 * Class:     IPC_formatters
 * Method:    findNamedFormat
 * Signature: (J)J
 */
JNIEXPORT jlong JNICALL Java_IPC_formatters_findNamedFormat
  (JNIEnv *, jclass, jlong);

/*
 * Class:     IPC_formatters
 * Method:    checkMarshallStatus
 * Signature: (J)Z
 */
JNIEXPORT jboolean JNICALL Java_IPC_formatters_checkMarshallStatus
  (JNIEnv *, jclass, jlong);

/*
 * Class:     IPC_formatters
 * Method:    createBuffer
 * Signature: (J)J
 */
JNIEXPORT jlong JNICALL Java_IPC_formatters_createBuffer
  (JNIEnv *, jclass, jlong);

/*
 * Class:     IPC_formatters
 * Method:    freeBuffer
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_IPC_formatters_freeBuffer
  (JNIEnv *, jclass, jlong);

/*
 * Class:     IPC_formatters
 * Method:    bufferLength
 * Signature: (J)I
 */
JNIEXPORT jint JNICALL Java_IPC_formatters_bufferLength
  (JNIEnv *, jclass, jlong);

/*
 * Class:     IPC_formatters
 * Method:    createByteArray
 * Signature: (I)J
 */
JNIEXPORT jlong JNICALL Java_IPC_formatters_createByteArray
  (JNIEnv *, jclass, jint);

/*
 * Class:     IPC_formatters
 * Method:    rewindBuffer
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_IPC_formatters_rewindBuffer
  (JNIEnv *, jclass, jlong);

/*
 * Class:     IPC_formatters
 * Method:    printBuffer
 * Signature: (J)V
 */
JNIEXPORT void JNICALL Java_IPC_formatters_printBuffer
  (JNIEnv *, jclass, jlong);

/*
 * Class:     IPC_formatters
 * Method:    printByteArray
 * Signature: (JI)V
 */
JNIEXPORT void JNICALL Java_IPC_formatters_printByteArray
  (JNIEnv *, jclass, jlong, jint);

/*
 * Class:     IPC_formatters
 * Method:    parseFormat
 * Signature: (Ljava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_IPC_formatters_parseFormat
  (JNIEnv *, jclass, jstring);

#ifdef __cplusplus
}
#endif
#endif
/* Header for class IPC_formatters_IPCString */

#ifndef _Included_IPC_formatters_IPCString
#define _Included_IPC_formatters_IPCString
#ifdef __cplusplus
extern "C" {
#endif
#ifdef __cplusplus
}
#endif
#endif
/* Header for class IPC_formatters_IPCDouble */

#ifndef _Included_IPC_formatters_IPCDouble
#define _Included_IPC_formatters_IPCDouble
#ifdef __cplusplus
extern "C" {
#endif
#ifdef __cplusplus
}
#endif
#endif
/* Header for class IPC_formatters_IPCFloat */

#ifndef _Included_IPC_formatters_IPCFloat
#define _Included_IPC_formatters_IPCFloat
#ifdef __cplusplus
extern "C" {
#endif
#ifdef __cplusplus
}
#endif
#endif
/* Header for class IPC_formatters_IPCLong */

#ifndef _Included_IPC_formatters_IPCLong
#define _Included_IPC_formatters_IPCLong
#ifdef __cplusplus
extern "C" {
#endif
#ifdef __cplusplus
}
#endif
#endif
/* Header for class IPC_formatters_IPCInteger */

#ifndef _Included_IPC_formatters_IPCInteger
#define _Included_IPC_formatters_IPCInteger
#ifdef __cplusplus
extern "C" {
#endif
#ifdef __cplusplus
}
#endif
#endif
/* Header for class IPC_formatters_IPCShort */

#ifndef _Included_IPC_formatters_IPCShort
#define _Included_IPC_formatters_IPCShort
#ifdef __cplusplus
extern "C" {
#endif
#ifdef __cplusplus
}
#endif
#endif
/* Header for class IPC_formatters_IPCByte */

#ifndef _Included_IPC_formatters_IPCByte
#define _Included_IPC_formatters_IPCByte
#ifdef __cplusplus
extern "C" {
#endif
#ifdef __cplusplus
}
#endif
#endif
/* Header for class IPC_formatters_IPCBoolean */

#ifndef _Included_IPC_formatters_IPCBoolean
#define _Included_IPC_formatters_IPCBoolean
#ifdef __cplusplus
extern "C" {
#endif
#ifdef __cplusplus
}
#endif
#endif
/* Header for class IPC_formatters_IPCChar */

#ifndef _Included_IPC_formatters_IPCChar
#define _Included_IPC_formatters_IPCChar
#ifdef __cplusplus
extern "C" {
#endif
#ifdef __cplusplus
}
#endif
#endif
/* Header for class IPC_formatters_IPCPrim */

#ifndef _Included_IPC_formatters_IPCPrim
#define _Included_IPC_formatters_IPCPrim
#ifdef __cplusplus
extern "C" {
#endif
#ifdef __cplusplus
}
#endif
#endif
/* Header for class IPC_formatters_VARCONTENT */

#ifndef _Included_IPC_formatters_VARCONTENT
#define _Included_IPC_formatters_VARCONTENT
#ifdef __cplusplus
extern "C" {
#endif
#ifdef __cplusplus
}
#endif
#endif
