
let run_test x =
  if x = true then CourseJson.runner "FS;lk;lAD"
  else ()


let main () = 
  ANSITerminal.(print_string [red]
                  "\n\nWelcome to Cornell Scheduler.\n");
  run_test true

let () = main ()
