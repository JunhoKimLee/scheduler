open Command

(** The type of class_id. (ex) ["CS";"3110"]) *)
type class_id = string list

(** The type of t, user survey answers, in record *)
type t = {
  semester: string;
  classes_input: class_id list;
  classtime_input: (string * string);
  lunch_input: string;
  spread_input: string;
}

type t_output = {
  final_semester: string;
  final_classes: (string * string) list;
  classtime: (int * int);
  lunch_output: string;
  spread_output: string;
}

let init_state = 
  {
    semester = "";
    classes_input = [];
    classtime_input = ("","");
    lunch_input = "";
    spread_input = "";
  }

let get_classes st = 
  let rec to_assoc_list list acc =
    match list with
    | [] -> acc
    | h::t when List.length h = 2 -> 
      to_assoc_list t ((List.nth h 0, List.nth h 1)::acc)
    | _ -> failwith "error" in
  to_assoc_list st.classes_input []

(** [time_to_min_output time] converts the time [time] in string (ex. "11:00")
    to minutes in int. *)
let time_to_min_output time = 
  let list = String.split_on_char ':' time in
  let hr = (list|> List.hd |> int_of_string) * 60 in
  let min = list |> List.rev |> List.hd |> int_of_string in
  hr+min

let get_class_time st = 
  (time_to_min_output (fst st.classtime_input),
   time_to_min_output (snd st.classtime_input))

let final_output st = {
  final_semester = st.semester;
  final_classes = get_classes st;
  classtime = get_class_time st;
  lunch_output = st.lunch_input;
  spread_output = st.spread_input;
}

(** [check_length tl] is true if for the string list [tl] with two elements,
    the length of first string (ex."CS") is between 2 and 5 and the length of 
    second string (ex."3110") is 4. False otherwise. *) 
let check_length tl = 
  match tl with
  | h::t::[] ->
    (String.length h >= 2 && String.length h <= 5) && (String.length t = 4)
  | _ -> false

(** [check_type tl] is true if for the string list [tl] with two elements,
    the first string has only non-numbers, and the second string has only
    numbers. False otherwise. *)
let check_type tl = 
  match tl with
  | h::t::[] ->
    begin
      (Str.string_match (Str.regexp "[^0-9]+$") h 0)
      && (Str.string_match (Str.regexp "[0-9]+$") t 0)
    end
  | _ -> false

let is_valid_class (tl:string list) =
  check_length tl && check_type tl

(** [is_valid_class_st st] is true if the inputted class is more than 3 classes
    and less than 9 classes, which generally satisfies the minimum and maximum
    credits required or available. *)
let is_valid_class_st st = 
  (List.length st.classes_input < 9) && (List.length st.classes_input > 1)

(** [check_sem sem] is true if the inputted string [sem] is either "SP" or "FA".
    Otherwise, it is false. *)
let check_sem sem = 
  sem = "SP" || sem = "FA"

(** [check_num hd] is true if the inputted number [hd] is a 4 digit string and 
    last 1-2 digit are number. Otherwise, it is false. *)
let check_num hd = 
  String.length hd = 4 && (Str.string_match (Str.regexp "[0-9]+$") hd 2)

let is_valid_sem (tl:string list) = 
  match tl with
  | hd::[] ->
    begin
      check_sem ((^) (String.get hd 0 |> Char.escaped)
                   (String.get hd 1 |> Char.escaped)) && check_num hd
    end
  | _ -> false

(** [is_valid_sem_st st] is true if the semester of current state [st] is not an
    empty string. *)
let is_valid_sem_st st = st.semester <> ""


let take_sem (st:t) tl = 
  if st.semester = "" then
    { st with
      semester = List.hd tl;
    }
  else
    st

let delete_sem (st:t) tl = 
  if st.semester = List.hd tl then
    { st with
      semester = "";
    }
  else
    st

let take_class (st:t) (tl:string list) = 
  { st with
    classes_input = tl :: st.classes_input
  }

let delete_class (st:t) (tl:string list) = 
  if List.mem tl st.classes_input then
    { st with
      classes_input = List.filter(fun x -> x <> tl) st.classes_input
    }
  else 
    st 

(** [is_valid_class_time_st st] is true if classtime_input of [st] is not an
    empty string for both start and end times. *)
let is_valid_class_time_st st = 
  match st.classtime_input with
  | (fst, snd) -> fst <> "" && snd <> ""

(** [str_list string] is a string list of non-space characters splitted on 
    character ':'. 
    Requires: [str] contains only alphanumeric (A-Z, a-z, 0-9) and space 
    characters (only ASCII character code 32; not tabs or newlines, etc.).*)
let str_to_list string =
  let list = String.split_on_char ':' string in 
  let rec helper list acc =
    match list with
    | [] -> List.rev acc
    | "" :: t -> helper t acc
    | h :: t -> helper t (h::acc) in 
  helper list []

(** [check_hour n] is true if the hour time [n] is an int in between 0 and 23
    inclusive. Otherwise, false. *)
let check_hour n = (int_of_string n) >= 0 && (int_of_string n) <= 23 

(** [check_min n] is true if the minute time [n] is an int in between 0 and 59 
    inclusive. Otherwise, false. *)
let check_min n = (int_of_string n) >= 0 && (int_of_string n) <= 59 

(** [check_num2 hd] is true if the inputted number string [hd] is all digit
    numbers. Otherwise, false. *)
let check_num2 hd = 
  (Str.string_match (Str.regexp "[0-9]+$") hd 0)

(** [check_time time] is true if [time] is a valid format of time (ex. "11:11").
    Otherwise, false. *)
let check_time time = 
  if String.length time = 5 && time.[2] = ':'
  then match (str_to_list time) with
    | hd::tl::[] ->
      check_num2 hd && check_num2 tl && check_hour hd && check_min tl 
    | _ -> false
  else false

(** [check_greater hd tl] is true if the second time [tl] is greater than the 
    first time [hd]. Otherwise, false. *)
let check_greater hd tl = 
  let hd_list = str_to_list hd in
  let tl_list = str_to_list tl in
  let hd_time = (hd_list |> List.hd |> int_of_string) * 60
                + (1 |> List.nth hd_list |> int_of_string) in
  let tl_time = (tl_list |> List.hd |> int_of_string) * 60
                + (1 |> List.nth tl_list |> int_of_string) in
  hd_time < tl_time

let is_valid_class_time tl = 
  match tl with
  | hd::tl::[] -> ((check_time hd) && (check_time tl)) && check_greater hd tl
  | _ -> false

let take_class_time st tl =   
  { st with
    classtime_input = (List.nth tl 0, List.nth tl 1)
  }

let delete_class_time st = 
  { st with
    classtime_input = ("","")
  } 

(** [is_valid_lunch_st st] is true if the lunch_input of current state [st] is
    not an empty string. *)
let is_valid_lunch_st st = st.lunch_input <> ""

(** [is_YN tl] is true if the answer string list [tl] is either "Y" or "N".
    Otherwise, false.
    Requires: [tl] must have length of one. *)
let is_YN tl = 
  match tl with
  | a::_ -> a = "Y" || a = "N"
  | _ -> failwith "Y or N answer more than one string"

(** [take_lunch st tl] is the user attempting to take a lunch preference [tl]
    as their answer to the survey question. The element of string list of
    'Y' or 'N' (ex. ["Y"]) is concatenated to the classtime_input of [st]. *)
let take_lunch st tl =   
  { st with
    lunch_input = List.hd tl 
  }

(** [delete_lunch st] is the user attempting to delete what has been
    inputted as their answer to the survey question. The lunch_input of [st] is 
    an empty string. *)
let delete_lunch st = 
  {st with lunch_input = ""}

(** [is_valid_spread_st st] is true if the spread_input of current state [st] is
    not an empty string. Otherwise, false. *)
let is_valid_spread_st st = st.spread_input <> ""

(** [take_spread st tl] is the user attempting to take spread preference [tl]
    as their answer to the survey question. The element of string list of
    'Y' or 'N' (ex. ["Y"]) is concatenated to the classtime_input of [st]. *)
let take_spread st tl =   
  { st with
    spread_input = List.hd tl 
  }

(** [delete_spread st] is the user attempting to delete what has been
    inputted as their answer to the survey question. The spread_input of [st] is 
    an empty string. *)
let delete_spread st = 
  {st with spread_input = ""}


(** [print_class_helper acc classes] is the string [acc] that concatenates all 
    the class_ids in the string list list[classes]*)
let rec print_class_helper acc classes=
  match classes with 
  | hd::tl -> print_class_helper (String.concat " " hd :: acc) tl
  | _ -> acc

(** [print_sem st] is the string that reveals the current input in the state 
    [st] for semester question prompt. *)
let print_sem = function
    { semester = sem } -> if sem = "" then "Semester not Specified."
    else "Currently selected semester: " ^ sem
         ^ "\nIf you would like to proceed, type next."

(** [print_class st] converts classes_input of [st] into a string with the correct
    format to be printed in the prompt. *)
let print_class = function
    { classes_input = classes } -> if classes = []
    then "Currently Entered Class IDs: None"
    else print_class_helper [] classes 
         |> String.concat ", " 
         |> (^) "Currently Entered Class IDs: " 

(** [print_class_time st] is the string that reveals the current input in the state
    [st] for class time question prompt. *)
let print_class_time = function
    { classtime_input = classtime } -> if classtime = ("","")
    then "You have not yet selected the start time and end time of your firs\
          t and last class"
    else "Start time of your first class: " ^ (fst classtime)
         ^ "\nEnd time of your last class: " ^ (snd classtime)

(** [print_lunch st] is the string that reveals the current input in the state
    [st] for lunch question prompt. *)
let print_lunch = function
    { lunch_input = lunchtime } -> if lunchtime = ""
    then "You have not yet selected your lunch flexibility preference."
    else "You have selected: " ^ lunchtime

(** [print_spread st] is the string that reveals the current input in the state
    [st] for spread question prompt. *)
let print_spread = function
    { spread_input = spread } -> if spread = ""
    then "You have not yet selected your class spread preference."
    else "You have selected: " ^ spread


let rec prompt_spread st = 
  ANSITerminal.(print_string [green] ((print_spread st)^"\n"));
  print_endline "Command take: Input 'Y' if you want your classes to be spread\
                 ed out and 'N' if you are want them clustered on certain day\
                 s. (Ex. take Y)";
  print_endline "Command delete: Delete the selected option for class spreaded\
                 ness (Ex. 'delete')";
  print_endline "Command next: Proceeding to the next question. (Ex. next)";
  print_endline "Command quit: Exit the program. (Ex. quit)";
  print_endline "\nPlease enter your preference on class spread (Y, N) (Command\
                 s: 'take', 'delete', 'next', 'quit')\n";
  print_string "> ";
  match parse_YN(read_line () |> String.uppercase_ascii) with
  | Quit -> init_state
  | Next -> if is_valid_spread_st st then st
    else (ANSITerminal.(
        print_string [red] ("You have not entered your preference yet.\n"));
       prompt_spread st)
  | Delete tl -> if is_valid_spread_st st then st |> delete_spread
                                               |> prompt_spread
    else (ANSITerminal.(
        print_string [red] ("You have not entered your preference yet \n"));
       prompt_spread st)
  | Take tl -> if is_YN tl then tl |> take_spread st  |> prompt_spread
    else (ANSITerminal.(
        print_string [red] ("Please enter in a valid format.\n"));
       prompt_spread st)
  | exception Malformed -> ANSITerminal.(
      print_string [red] ("Please use a valid command statement.\n"));
    prompt_spread st
  | exception Empty -> ANSITerminal.(
      print_string [red] ("Your input was empty.\n")); prompt_spread st

let rec prompt_lunch st = 
  ANSITerminal.(print_string [green] ((print_lunch st)^"\n"));
  print_endline "Command take: Input 'Y' if you are flexible with lunch time a\
                 nd 'N' if you are not (Flexible lunch time means occassionall\
                 y having lunch before 11 or after 1pm) (Ex. take Y)";
  print_endline "Command delete: Delete the selected option for lunch (Ex. 'de\
                 lete')";
  print_endline "Command next: Proceeding to the next question. (Ex. next)";
  print_endline "Command quit: Exit the program. (Ex. quit)";
  print_endline "\nPlease enter your flexibility on lunch (Y, N) (Commands: 't\
                 ake', 'delete', 'next', 'quit')\n";
  print_string "> ";
  match parse_YN(read_line () |> String.uppercase_ascii) with
  | Quit -> init_state
  | Next -> if is_valid_lunch_st st then prompt_spread st
    else (ANSITerminal.(
        print_string [red] ("You have not entered your preference yet.\n"));
       prompt_lunch st)
  | Delete tl -> if is_valid_lunch_st st then st |> delete_lunch |> prompt_lunch
    else (ANSITerminal.(
        print_string [red] ("You have not entered your preference yet. \n"));
       prompt_lunch st)
  | Take tl -> if is_YN tl then tl |> take_lunch st  |> prompt_lunch
    else (ANSITerminal.(
        print_string [red] ("Please enter in a valid format.\n"));
       prompt_lunch st)
  | exception Malformed -> ANSITerminal.(
      print_string [red] ("Please use a valid command statement.\n"));
    prompt_lunch st
  | exception Empty -> ANSITerminal.(
      print_string [red] ("Your input was empty.\n")); prompt_lunch st

let rec prompt_class_time st = 
  ANSITerminal.(print_string [green] ((print_class_time st)^"\n"));
  print_endline "Command take: Input the preferred start time of your first cl\
                 ass and end time of your last class in 24hr format (Ex. 'tak\
                 e 10:10 18:00' --> your first class start time is 8AM and las\
                 t class end time is 6PM) (00:00 - 23:59) ";
  print_endline "Command delete: Delete the selected start time and end tim\
                 e. (Ex. 'delete')";
  print_endline "Command next: Proceeding to the next question. (Ex. next)";
  print_endline "Command quit: Exit the program. (Ex. quit)";
  print_endline "\nPlease enter your preferred first and last class start/end t\
                 imes in order. (Commands: 'take', 'delete', 'next', 'quit')\n";
  print_string "> ";
  match parse_class_time(read_line () |> String.uppercase_ascii) with
  | Quit -> init_state
  | Next -> if is_valid_class_time_st st then prompt_lunch st
    else (ANSITerminal.(
        print_string [red] ("You have not inputted times yet.\n"));
       prompt_class_time st)
  | Delete tl -> if is_valid_class_time_st st then st |> delete_class_time
                                                   |> prompt_class_time
    else (ANSITerminal.(
        print_string [red] ("You have not entered preferred times yet. \n"));
       prompt_class_time st)
  | Take tl -> if is_valid_class_time tl then tl |> take_class_time st 
                                              |> prompt_class_time
    else (ANSITerminal.(
        print_string [red] ("Please enter in a valid format.\n"));
       prompt_class_time st)
  | exception Malformed -> ANSITerminal.(
      print_string [red] ("Please use a valid command statement.\n"));
    prompt_class_time st
  | exception Empty -> ANSITerminal.(
      print_string [red] ("Your input was empty.\n")); prompt_class_time st


let rec prompt_class st = 
  ANSITerminal.(print_string [green] ((print_class st)^"\n"));
  print_endline "Command take: Input the class that you want to enroll in wit\
                 h a space in between the department and the class numbe\
                 r. (Ex. 'take CS 3110')";
  print_endline "Command delete: Input the class that you want to delete from y\
                 our preferred class list. (Ex. 'delete CS 3110')";
  print_endline "Command next: Proceeding to the next question. (Ex. next)";
  print_endline "Command quit: Exit the program. (Ex. quit)";
  print_endline "\nPlease enter a course id that you would like to enroll i\
                 n. (Commands: 'take', 'delete', 'next', 'quit')\n";
  print_string "> ";
  match parse_class(read_line () |> String.uppercase_ascii) with
  | Quit -> init_state
  | Next -> if is_valid_class_st st then prompt_class_time st
    else (ANSITerminal.(
        print_string [red] ("You have too little(less than 2) or too much(m\
                             ore than 9) classes to proceed.\n"));
       prompt_class st)
  | Delete tl when is_valid_class tl -> if ((tl |> delete_class st) <> st)
    then tl |> delete_class st |> prompt_class 
    else (ANSITerminal.(
        print_string [red] ("You can only delete one of the selected classe\
                             s.\n"));
       prompt_class st)
  | Delete tl -> ANSITerminal.(
      print_string [red] ("Please enter a class in the valid format.\n"));
    prompt_class st
  | Take tl -> if is_valid_class tl then tl |> take_class st |> prompt_class 
    else (ANSITerminal.(
        print_string [red] ("Please enter in a valid format.\n"));
       prompt_class st)
  | exception Malformed -> ANSITerminal.(
      print_string [red] ("Please use a valid command statement.\n"));
    prompt_class st
  | exception Empty -> ANSITerminal.(
      print_string [red] ("Your input was empty.\n"));
    prompt_class st


let rec prompt_semester st = 
  ANSITerminal.(print_string [green] ((print_sem st)^"\n"));
  print_endline "Command take: Input the semester that you want to get a s\
                 chedule for: Abbreviation of the term of the semester with t\
                 wo digit number for year combined. (Ex. 'take SP20')";
  print_endline "Command delete: Delete the selected semester. (Ex. 'delete S\
                 P20')";
  print_endline "Command next: Proceeding to the next question. (Ex. next)";
  print_endline "Command quit: Exit the program. (Ex. quit)";
  print_endline "Please enter the semester that you would like to get a schedu\
                 le for. (Commands: 'take', 'delete', 'next', 'quit')\n";
  print_string "> ";
  match parse_semester(read_line () |> String.uppercase_ascii) with
  | Quit -> init_state
  | Next -> if is_valid_sem_st st then prompt_class st
    else (ANSITerminal.(print_string [red] (
        "You have not selected a semester to proceed with. \n"
      )); prompt_semester st)
  | Delete tl when is_valid_sem tl -> if ((tl |> delete_sem st) <> st)
    then tl |> delete_sem st |> prompt_semester
    else (ANSITerminal.(print_string [red] (
        "You can only delete the selected semester.\n")); prompt_semester st)
  | Delete tl -> ANSITerminal.(print_string [red] (
      "Please enter the semester in a valid format.\n")); prompt_semester st
  | Take tl when is_valid_sem tl -> if ((tl |> take_sem st) <> st)
    then tl |> take_sem st |> prompt_semester
    else (ANSITerminal.(print_string [red] (
        "You have already selected a semester.\n")); prompt_semester st)
  | Take tl -> ANSITerminal.(print_string [red] (
      "Please enter the semester in a valid format.\n")); prompt_semester st
  | exception Malformed -> ANSITerminal.(print_string [red] (
      "Please use a valid command statement.\n")); prompt_semester st
  | exception Empty -> ANSITerminal.(print_string [red] (
      "Your input was empty.\n")); prompt_semester st