#![allow(non_snake_case)]

use core::alloc::Layout;
use core::ffi::c_void;
use core::mem::{ManuallyDrop, MaybeUninit};
use crossterm::execute;
use crossterm;
use libc;
use roc_std::RocStr;
use std::ffi::CStr;
use std::os::raw::c_char;
use std::panic::catch_unwind;
use std::time::Duration;

static mut START_TIME: Option<std::time::Instant> = None;

extern "C" {
    #[link_name = "roc__mainForHost_1_exposed_generic"]
    fn roc_main(output: *mut u8) -> ();

    #[link_name = "roc__mainForHost_size"]
    fn roc_main_size() -> i64;

    #[link_name = "roc__mainForHost_1_Fx_caller"]
    fn call_Fx(flags: *const u8, closure_data: *const u8, output: *mut u8) -> ();

    #[allow(dead_code)]
    #[link_name = "roc__mainForHost_1_Fx_size"]
    fn size_Fx() -> i64;

    #[link_name = "roc__mainForHost_1_Fx_result_size"]
    fn size_Fx_result() -> i64;
}

#[no_mangle]
pub unsafe extern "C" fn roc_alloc(size: usize, _alignment: u32) -> *mut c_void {
    libc::malloc(size)
}

#[no_mangle]
pub unsafe extern "C" fn roc_realloc(
    c_ptr: *mut c_void,
    new_size: usize,
    _old_size: usize,
    _alignment: u32,
) -> *mut c_void {
    libc::realloc(c_ptr, new_size)
}

#[no_mangle]
pub unsafe extern "C" fn roc_dealloc(c_ptr: *mut c_void, _alignment: u32) {
    libc::free(c_ptr)
}

#[no_mangle]
pub unsafe extern "C" fn roc_panic(c_ptr: *mut c_void, tag_id: u32) {
    match tag_id {
        0 => {
            let slice = CStr::from_ptr(c_ptr as *const c_char);
            let string = slice.to_str().unwrap();
            eprintln!("Roc hit a panic: {}", string);
            std::process::exit(1);
        }
        _ => todo!(),
    }
}

#[no_mangle]
pub unsafe extern "C" fn roc_memcpy(dst: *mut c_void, src: *mut c_void, n: usize) -> *mut c_void {
    libc::memcpy(dst, src, n)
}

#[no_mangle]
pub unsafe extern "C" fn roc_memset(dst: *mut c_void, c: i32, n: usize) -> *mut c_void {
    libc::memset(dst, c, n)
}

unsafe fn execute_main() -> i32 {
    
    START_TIME = Some(std::time::Instant::now());
    
    let size = unsafe { roc_main_size() } as usize;
    let layout = Layout::array::<u8>(size).unwrap();
    
    // TODO allocate on the stack if it's under a certain size
    let buffer = std::alloc::alloc(layout);

    roc_main(buffer);

    let result = call_the_closure(buffer);

    std::alloc::dealloc(buffer, layout);

    return result;
}

#[no_mangle]
pub extern "C" fn rust_main() -> i32 {
    let result = unsafe
    {
        match catch_unwind(|| execute_main()) {
            Ok(result) => result,
            Err(_) => 1
        }
    };
    
    crossterm::terminal::disable_raw_mode();
    execute!(std::io::stdout(),
        crossterm::cursor::Show,
        crossterm::style::SetForegroundColor(crossterm::style::Color::Reset),
        crossterm::style::SetBackgroundColor(crossterm::style::Color::Reset)
    );
    
    result
}

unsafe fn call_the_closure(closure_data_ptr: *const u8) -> i32 {
    let size = size_Fx_result() as usize;
    let layout = Layout::array::<u8>(size).unwrap();
    let buffer = std::alloc::alloc(layout) as *mut u8;

    call_Fx(
        // This flags pointer will never get dereferenced
        MaybeUninit::uninit().as_ptr(),
        closure_data_ptr as *const u8,
        buffer as *mut u8,
    );

    std::alloc::dealloc(buffer, layout);

    0
}

#[no_mangle]
pub extern "C" fn roc_fx_getLine() -> RocStr {
    use std::io::{self, BufRead};

    let stdin = io::stdin();
    let line1 = stdin.lock().lines().next().unwrap().unwrap();

    RocStr::from(line1.as_str())
}

#[no_mangle]
pub extern "C" fn roc_fx_putLine(line: ManuallyDrop<RocStr>) {
    let string = line.as_str();
    println!("{}", string);
}

#[no_mangle]
pub extern "C" fn roc_fx_put(line: ManuallyDrop<RocStr>) {
    let string = line.as_str();
    print!("{}", string);
}

#[no_mangle]
pub extern "C" fn roc_fx_terminalRawMode(raw: bool) {
    if raw {
        crossterm::terminal::enable_raw_mode();
    }
    else {
        crossterm::terminal::disable_raw_mode();
    }
}

#[no_mangle]
pub extern "C" fn roc_fx_terminalClear() {
    execute!(std::io::stdout(), crossterm::terminal::Clear(crossterm::terminal::ClearType::All));
}

#[no_mangle]
pub extern "C" fn roc_fx_terminalSetCursorVisible(visible: bool) {
    if visible {
        execute!(std::io::stdout(), crossterm::cursor::Show);
    }
    else {
        execute!(std::io::stdout(), crossterm::cursor::Hide);
    }
}

#[no_mangle]
pub extern "C" fn roc_fx_terminalGoto(x: u16, y: u16) {
    execute!(std::io::stdout(), crossterm::cursor::MoveTo(x,y));
}

#[no_mangle]
pub extern "C" fn roc_fx_sleep(seconds: f64) {
    let duration = Duration::from_nanos((seconds * 1e9).round() as u64);
    std::thread::sleep(duration);
}

#[no_mangle]
pub extern "C" fn roc_fx_terminalNextKey() -> RocStr {
    let str = match crossterm::event::poll(Duration::from_millis(1)) {
        Ok(true) => {
            match crossterm::event::read() {
                Ok(crossterm::event::Event::Key(key)) => {
                    let result = format!("{:?}", key);
                    result
                }
                _ => String::from("")
            }
        }
        _ => String::from("")
    };

    RocStr::from(str.as_str())
}

#[no_mangle]
pub extern "C" fn roc_fx_terminalForecolor(r: u8, g:u8, b:u8) {
    execute!(
        std::io::stdout(),
        crossterm::style::SetForegroundColor(crossterm::style::Color::Rgb { r: r, g: g, b: b }));
}

#[no_mangle]
pub extern "C" fn roc_fx_terminalForecolorReset() {
    execute!(
        std::io::stdout(),
        crossterm::style::SetForegroundColor(crossterm::style::Color::Reset));
}

#[no_mangle]
pub extern "C" fn roc_fx_terminalBackcolor(r: u8, g:u8, b:u8) {
    execute!(
        std::io::stdout(),
        crossterm::style::SetBackgroundColor(crossterm::style::Color::Rgb { r: r, g: g, b: b }));
}

#[no_mangle]
pub extern "C" fn roc_fx_terminalBackcolorReset() {
    execute!(
        std::io::stdout(),
        crossterm::style::SetBackgroundColor(crossterm::style::Color::Reset));
}

#[no_mangle]
pub extern "C" fn roc_fx_randomU32() -> u32 {
    rand::random::<u32>()
}

#[no_mangle]
pub extern "C" fn roc_fx_timeAppSeconds() -> f64 {
    unsafe {
        match START_TIME {
            None => 0.0,
            Some(instant) => {
                instant.elapsed().as_secs_f64()
            }
        }
    }
}