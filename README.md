
# Movie Posters Application

This web application allows you to search download to your personal device any movie poster you like.

# Technologies Used 

 - Python Flask 
 - MongoDB 
 - aws cloud
 - terraform
 - docker



# Prerequisites to make it work

1) TMDB API key - open an account at this link https://www.themoviedb.org/signup
2) navigate to [https://www.themoviedb.org/settings/api](https://www.themoviedb.org/settings/api) 


![image](https://user-images.githubusercontent.com/82024584/175266047-08932034-ba51-4b0d-80f6-f449da33820f.png)

3) generate an API Key
4) ![image](https://user-images.githubusercontent.com/82024584/175267304-7561208b-8804-4ed8-a82e-2dba984a0f25.png)
5) make a new file in the same folder as the project and name it config.py and put inside the api key and save.
6) ![image](https://user-images.githubusercontent.com/82024584/175267611-861f98bf-074a-4e35-82f5-4698d408adb9.png)
7) Use Access keys in terraform to bring the infrastructure up in 1-click, put them in main.tf

![image](https://user-images.githubusercontent.com/82024584/175268336-9338577a-f160-491c-bf57-e980515b5f6f.png)

8) At this point all is left to do is to run the commands - terraform init, terraform plan, terraform apply. 
9) When done, use terraform destroy.

# Architecture:

![architecture]()

# Demo:

![ProjectDemoGIF800](https://user-images.githubusercontent.com/82024584/168753125-3f54a942-a2f2-4795-bf0e-0eb313374416.gif)

# Flow Chart:

![ProjectFlowChart](https://user-images.githubusercontent.com/82024584/168774364-a427dfd5-a9c2-4581-9c18-71531f6dbb0b.PNG)
