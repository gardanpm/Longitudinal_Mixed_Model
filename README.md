# Longitudinal Data and Mixed Models

Duke Sta 610, Hierarchical Modeling, Homework 4

The app can be found here [https://gardanpm.shinyapps.io/longMM/](https://gardanpm.shinyapps.io/longMM/).
To see the code, click on the code box on the top right of the second tab and select "Show All Code".

The repo for the app is in the longMM folder.

## Multilevel Modeling Insights

Your assignment is to create a helpful tool that illustrates an important aspect of understanding and use of multilevel models. This tool could be an interesting visualization, a Shiny app, or just an extraordinarily clear example illustration/mini-lecture! This is very open-ended so be as creative as possible!


Concept your tool is designed to illustrate;
Method by which this concept is illustrated (e.g., describing the functionality of a Shiny app or type of content delivered);
Any relevant references important to development of your tool.
Your pdf report MUST also contain a link to your tool, if you have one. If you do not have a link, upload a zipped folder containing the files for said tool.


## My report:

For this homework, I decided to illustrate how mixed effects models handle longitudinal data and also tried to touch on some of their capabilities. I built a Shiny app with three different tabs. The first tab introduces longitudinal data and explains how linear mixed model are more appropriate to model this type of data compre to linear models. The second tab goes over two example using the China Health and Nutrition Study (CHNS) Household Income dataset. The first example is quite simple and aims at illustrating how to conduct an analysis with repeated measure on subjects over time and the second example extends this analysis to a multivariate model with nested random effects. This tabs also allows to visualize predictions for individual households and to visually compare the two models. The third tab talks about the possibility of errors that are time dependent within subjects. It introduces the `nlme` package and the `lme` function. It goes over two examples assuming an AR1 correlation meaning that the errors covariance between two observations of the same subject decays when they are further appart in time. 

#### Longitudinal Data & Linear Mixed Models

Longitudinal studies present many challenges such as participants follow-up (drop-outs, etc.) or correlation in the data. Indeed, repeated measures on the same subject over time induce intra-subject correlation. However, "standard" analysis methods such as linear or generalised linear regression assume independence of observations. They allow for inference on the average response trajectory over time and how its variation across treatments and other characteristics. Unfortunatelly, using them on correlated data can cause standard errors and be p-values to be innacurate and overall inference to be invalid. If a subject's observations are highly correlated in time, then the information on this subject is actually smaller than nj observations. A good way to deal with this issue is to use mixed modeling, an extension of linear models. Mixed models assume random errors within a subject and random variation in the trajectory across subjects. It allows to specify subjects specific intercept and slope. Mixed effects models overlap in many ways with hierarchical models

We can define the random error called "within subjects" for measurement j of subject i as the deviation between Y_ij and the subject i trajectory.

A simple mixed model for a longitudinal study involving a continuous response Y and time as predictor with random intercept and slope for time by subjects could be specified as the following:

For i representing the index for subjects and j the index the index for time,

$$y_{i,j} = x_{i, j}\beta + \alpha_i \times Z_{i,j} +\epsilon_{i,j}$$
$x_{i, j}$ is the fixed effects vector (here intercept and time) for subject i at time j. $\beta$ is the vector of coefficients corresponding to these fixed effects.
$Z_{i,j}$ is the random effects vector (here a random intercept and a random slope for time) for subject i at time j.  
$\alpha_i$ is the vector of random coefficients for subject i. 
$\epsilon_{i,j} \sim N(0, \sigma^2)$ is the error for subject i at time j.

$$\alpha_i = {b_{0,i} \choose b_{1,i}} \sim N(0,
\begin{matrix}
  \tau_{11} & \tau_{12}\\
  \tau_{21} & \tau_{22} \end{matrix}) \:\perp \!\!\! \perp \: \epsilon_{i,j}$$


We could also have a model called a random intercept that would assumes different intercepts across subjects but parallel slopes by removing the random slope for time. Finally, when more than one predictor are involved, the effects of some variables might be different across subjects (include random slope) while others might not (only main fixed effect).

#### Autoregressive specification of the error variance: 

The models that we have seen so far assumed independent errors within groups. i.e, the variance-covariance matrix $\Sigma$ or sometimes called $R_i$ of the errors of these models is:

$$\Sigma = \sigma^2I=
\begin{bmatrix}
  1 & 0 & 0 & ... & 0 \\
  0 & 1 & 0 & ... & 0 \\
  . & . & . &     & .\\
  . & . & . &     & .\\
  . & . & . &     & .\\
  0 & 0 & 0 & ... & 1
\end{bmatrix}$$
However, the covariance might be non-zero. There could for example temporal dependence within groups. A way to express this type of dependence is the auto-regressive
correlation model. It uses a single correlation parameter $\rho$ ($-1 < \rho < 1$)and assumes that the
time separation between measurements determines their correlation. In our model, it would be:
$$corr(Y_{i,k,j}, Y_{i,k,j'}) = ρ^{|tj−tj'|}$$
For example, if $\rho = 0.8$ and observations are 10 years
apart, their correlation will be $0.8^{10} = 0.107$. In an auto-regressive model the
correlation will decay as the distance betweeen observations increases. $\rho$ is estimated from the data. The `lmer` function that we had been using cannot handle such specification and so we use `lme` form the `nlme` package.

This new $\Sigma$ matrix can be expressed as the following, for m time points:
$$\Sigma = \sigma^2
\begin{bmatrix}
  1 & \rho & \rho^2 & ... & \rho^{m-1} \\
  \rho & 1 & \rho & ... & \rho^{m-2} \\
  . & . & . &     & .\\
  . & . & . &     & .\\
  . & . & . &     & .\\
  \rho^{m-1} & \rho^{m-2} & ... & \rho & 1
\end{bmatrix}$$


#### References: 

- Arnab Maity, Longitudinal Data Analysis: Linear Mixed Effects Models, NCSU Department of Statistics, 2020.
- Peter D. Hoff, Lecture Notes on Hierarchical Modeling, 2019.
- This analysis uses data from China Health and Nutrition Survey (CHNS). We thank the National Institute of Nutrition and Food Safety, China Center for Disease Control and Prevention, Carolina Population Center, the University of North Carolina at Chapel Hill, the NIH (R01-HD30880, DK056350, and R01-HD38700) and the Fogarty International Center, NIH for financial support for the CHNS data collection and analysis files from 1989 to 2006 and both parties plus the China-Japan Friendship Hospital, Ministry of Health for support for CHNS 2009 and future surveys.
