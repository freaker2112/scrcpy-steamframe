project('scrcpy', 'c',
        version: '5.0.1',
        meson_version: '>= 0.49',
        default_options: [
            'c_std=c11',
            'warning_level=2',
            'b_ndebug=if-release',
        ])

add_project_arguments('-Wmissing-prototypes', language: 'c')

sdl3_dep = dependency('sdl3',
  required: true,
  static: true,
  fallback: ['sdl3', 'sdl3_dep']
)

if get_option('compile_app')
    subdir('app')
endif

if get_option('compile_server')
    subdir('server')
endif
