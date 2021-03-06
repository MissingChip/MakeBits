#top down build - topmost directory is required by all things

#lib info
#	(can be user-controlled)
flags :=
obj_stub := obj
lib_stub := lib
lib_ext := .a
lib_name := $(shell printf '%s' "$${PWD\#\#*/}")
dec_dir := .
def_dir := .


#automatic info
flags += $(uni_flags)
directories = $(sort $(dir $(filter ./%/, $(wildcard ./*/))))
lib_q := $(filter-out ./$(obj_stub)/ ./$(lib_stub)/, $(directories))

ifeq (,$(lib_dir))
lib_dir := lib
endif
lib_file := $(lib_dir)/lib$(lib_name).$(lib_ext) #the archive file to 
obj_dir := $(obj_stub)
objs = $(patsubst %.cpp, $(obj_dir)/%.o, $(wildcard *.cpp))
decs = $(wildcard $(dec_dir)/*.h) $(wildcard $(dec_dir)/*.hpp) #header files (declarations)

ifeq (,$(objs))
lib_file := 
lib_name := 
endif


#all child libs, and this lib, if they exist
lib: $(lib_q) $(lib_file)
.PHONY: lib

$(lib_q): $(lib_file)
	@make -C ./$@ lib_dir=../$(lib_dir) lib_deps="$(lib_name) $(lib_deps)" inc_dirs="$(patsubst %, ../%, $(inc_dirs)) ../$(dec_dir)" uni_flags=$(uni_flags)
.PHONY: $(lib_q)

$(lib_file): $(objs)
	@rm -f $@
	@mkdir -p $(lib_dir)
	ar -rcs $@ $(objs)

$(obj_dir)/%.o: %.cpp $(decs) $(patsubst %, $(lib_dir)/lib%.$(lib_ext), $(lib_deps))
	@mkdir -p $(obj_dir)
	@echo compile $< $(patsubst %, -l%, $(lib_deps))
	@$(CXX) -c -o $@ $< $(CXXFLAGS) -L$(lib_dir) $(patsubst %, -l%, $(lib_deps)) $(patsubst %, -I%, $(inc_dirs)) $(flags) -I.

