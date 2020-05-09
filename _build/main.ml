(** Returns a roster of type [Classes] containing data from [roster] and new
    data from the class [c] in semester [s]. *)
let rec get_class s c roster =
  match c with
  | [] -> roster
  | (a,b)::t ->
    begin
      CourseJson.runner s a b;
      let j = Yojson.Basic.from_file (s ^ "_" ^ a ^ "_" ^ b ^ ".json") in
      get_class s t (Classes.from_json j roster)
    end

let main () = 
  ANSITerminal.(print_string [blue]
                  "\n\nWelcome to Cornell Scheduler.\n");

  let st = UserSurvey.init_state |> UserSurvey.prompt_semester |> UserSurvey.final_output in
  let s = st.final_semester and
    c = st.final_classes in
  let r = get_class s c Classes.empty in
  let raw_schedule = r |> Schedule.schedule_maker in
  print_endline ("Number of schedule combinations: " ^ (raw_schedule |> List.length |> string_of_int));
  let refined_schedule = raw_schedule |> Algorithm.filter_valid_schedule [] in
  print_endline ("Number of non-conflicting schedule combinations: " ^ (refined_schedule |> List.length |> string_of_int))

let () = main ()