
#ifndef VOICE_INTERFACE_H_
#define VOICE_INTERFACE_H_

#include <Python.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LISTENDED_STRING_SIZE	1024
/*
* Initiate Python interpreter and verify module
*/
char *init_voice(char *language_code);

/*
* Finalize Python interpreter and "decrement" Python variables
*/
void finalize_voice();

/*
* Transforms current text in audio
*/
int speak(char *text, char *speech_file_name);

/*
* Enable Microfone to output a text from an audio
*/
void listen(char *listened_string);

#endif /* _VOICE_INTERFACE_H_ */
