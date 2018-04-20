package com.app.controller;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import com.app.pojo.User;
import com.app.service.IUserService;

@Controller  
@RequestMapping("/user") 
public class UserController {
	@Resource  
    private IUserService userService;  
	
	
	@RequestMapping("/index")  
    public String toIndex(HttpServletRequest request,Model model){  
        return "index";
    }
      
    @RequestMapping("/showUser")  
    public String toShowUser(HttpServletRequest request,Model model){  
        int userId = Integer.parseInt(request.getParameter("id"));  
        User user = this.userService.getUserById(userId);  
        model.addAttribute("user", user);  
        return "showUser";
    }
}
