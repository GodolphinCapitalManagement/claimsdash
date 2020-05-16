import joblib
import datetime

import warnings
warnings.simplefilter(action="ignore", category=FutureWarning)

import pandas as pd
import numpy as np

from fredapi import Fred
START_DATE = datetime.date(1995, 1, 1)
FRED_API_KEY = 'fcbbe7992aa80d097aed20dd9d7b2ed3'

import us
states = [x.abbr for x in us.STATES] 

def project_claims(state, covid_wt, sum_df, epi_enc, trace, verbose=False):
    ''' get labor market data from STL '''
    
    A = 0
    κ = trace["κ"]
    β = trace["β"]
    
    def states_data(suffix, state, fred):
        ''' gets data from FRED for a list of indices '''

 
        idx = "ICSA" if state == "US" else state + suffix            
        x =  pd.Series(
                fred.get_series(
                    idx, observation_start=START_DATE), name=idx
            )

        x.name = state

        return x    
    
    def forecast_claims(initval, initdate, enddate, covid_wt):
        ''' project initial claims '''
    
        μ_β = sum_df.loc["β", "mean"]
        μ_κ = sum_df.loc[["κ: COVID", "κ: Katrina"], "mean"].values
        μ_decay = covid_wt * μ_κ[0] + (1 - covid_wt) * μ_κ[1]
        
        dt_range = (
            pd.date_range(start=initdate, end=enddate, freq="W") - 
            pd.tseries.offsets.Day(1)
        )
        max_x = len(dt_range)
        
        w = np.arange(max_x)
        covid_idx = list(epi_enc.classes_).index("COVID")
        katrina_idx = list(epi_enc.classes_).index("Katrina")
        
        decay = (
          covid_wt * κ[:, covid_idx] + 
          (1 - covid_wt) * κ[:, katrina_idx]
        )
        μ = np.exp(-decay * np.power(w.reshape(-1, 1), β))
        
        μ_df = pd.DataFrame(
            np.percentile(μ, q=[5, 25, 50, 75, 95], axis=1).T, 
            columns=["5th", "25th", "50th", "75th", "95th"]
        ) * initval
        μ_df["period"] = w
           
        ic = np.zeros(max_x)
        ic[0] = 1
        for j in np.arange(1, max_x, 1):
            ic[j] = np.exp(-μ_decay * np.power(j, μ_β))
        
        df = pd.concat(
            [
                pd.Series(np.arange(max_x), name="period"),
                pd.Series(ic, name="ic_ratio"),
                pd.Series(ic * initval, name="ic"),
                pd.Series((ic * initval).cumsum(), name="cum_ic")
            ], axis=1
        )
    
        df.index = dt_range
        μ_df.index = dt_range
    
        return df, μ_df
    
    fred = Fred(api_key=FRED_API_KEY)
    ic_raw = states_data("ICLAIMS", state, fred)

    init_value, init_date, last_date = (
      ic_raw[ic_raw.idxmax()], ic_raw.idxmax(), ic_raw.index[-1]
    )
    end_date  = last_date + pd.tseries.offsets.QuarterEnd() 
    if verbose:
        print(
          f'State: {state}, {init_value}, {init_date}, '
          f'{end_date}, {last_date}'
        )
    
    ic_fct, ic_pct = forecast_claims(
      init_value, init_date, end_date, covid_wt
    )
    ic_fct["state"] = state
    ic_pct["state"] = state
    
    ic_pct = ic_pct.reset_index().rename(columns={"index": "obsdate"})
    return ic_pct, last_date.date().isoformat()
    
    
def read_pickled(fname):
  with open(fname, "rb") as f:
      claims_dict = joblib.load(f)
  return claims_dict
